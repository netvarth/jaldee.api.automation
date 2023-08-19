*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${Email}     email

*** Test Cases ***


JD-TC-GetOrderSetingsStoreContactInfo-1
    [Documentation]    Get Order Settings StoreContact Info.
    
    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_maxpartysize_subdomain
    Set Test Variable   ${sector}        ${resp['domain']}
    Set Test Variable   ${sub_sector}    ${resp['subdomain']}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+575552
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_A}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Suite Variable   ${PUSERNAME_A}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${fname}  ${decrypted_data['firstName']}
    Set Suite Variable  ${lname}  ${decrypted_data['lastName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}  ${resp.json()['lastName']}
    
    ${prov_accid1}=  get_acc_id  ${PUSERNAME_A}
    Set Suite Variable  ${prov_accid1}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_A}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_A}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   1s

    ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable  ${email_id_PA}  ${P_Email}${PUSERNAME_A}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${email_id_PA}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${prov_accid1}=  get_acc_id  ${PUSERNAME_A}
    Set Suite Variable  ${prov_accid1}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get StoreContact Info    ${prov_accid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['phone']}      ${PUSERNAME_A}
    Should Be Equal As Strings  ${resp.json()['email']}      ${email_id_PA}
   
JD-TC-GetOrderSetingsStoreContactInfo-2
    [Documentation]    Get Order Settings StoreContact Info WITHOUT ENABLE ORDER.
    
    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_maxpartysize_subdomain
    Set Test Variable   ${sector}        ${resp['domain']}
    Set Test Variable   ${sub_sector}    ${resp['subdomain']}
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+575553
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_B}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Suite Variable   ${PUSERNAME_B}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${decrypted_data['firstName']}
    Set Test Variable  ${lname}  ${decrypted_data['lastName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${fname}  ${resp.json()['firstName']}
    # Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   1s

    ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_B}.ynwtest@netvarth.com

    # ${resp}=  Update Email   ${p_id}   ${f_name}  ${l_name}   ${email_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${prov_accid2}=  get_acc_id  ${PUSERNAME_B}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get StoreContact Info    ${prov_accid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['phone']}      ${PUSERNAME_B}
    Should Not Contain    ${resp.json()}   ${Email}
    
JD-TC-GetOrderSetingsStoreContactInfo-3
    [Documentation]    Get Order Settings StoreContact Info By provider login.
    
    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_maxpartysize_subdomain
    Set Test Variable   ${sector}        ${resp['domain']}
    Set Test Variable   ${sub_sector}    ${resp['subdomain']}
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+575557
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_C}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Suite Variable   ${PUSERNAME_C}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${decrypted_data['firstName']}
    Set Test Variable  ${lname}  ${decrypted_data['lastName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${fname}  ${resp.json()['firstName']}
    # Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   1s

    ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_C}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${prov_accid3}=  get_acc_id  ${PUSERNAME_C}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get StoreContact Info    ${prov_accid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['phone']}      ${PUSERNAME_C}
    Should Be Equal As Strings  ${resp.json()['email']}      ${email_id}

JD-TC-GetOrderSetingsStoreContactInfo-4
    [Documentation]    Get StoreContact Info without login.

    ${resp}=   Get StoreContact Info    ${prov_accid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings  ${resp.json()['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['phone']}      ${PUSERNAME_A}
    Should Be Equal As Strings  ${resp.json()['email']}      ${email_id_PA}
   