*** Settings ***

Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        NotificationSettings
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***
${digits}       0123456789
@{EMPTY_List} 
@{person_ahead}   0  1  2  3  4  5  6
${self}         0
@{service_duration}   5   20
${parallel}     1
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf

*** Test Cases ***

JD-TC-User Consumer Communication-1
	[Documentation]   User communicate with consumers

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+6057217
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E1}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E1}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_E1}${\n}
     Set Suite Variable  ${MUSERNAME_E1}
     ${id}=  get_id  ${MUSERNAME_E1}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${MUSERNAME_E1}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_E1}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
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
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  30
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    
    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+591187
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+592287
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    ${pin2}=  get_pincode

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}

    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
    Set Suite Variable   ${p_id}

    ${cR_id15}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cR_id15}
    clear_Consumermsg  ${CUSERNAME15}
    ${cR_id17}=  get_id  ${CUSERNAME17}
    Set Suite Variable   ${cR_id17}
    clear_Consumermsg  ${CUSERNAME17}
    

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id1}=  get_acc_id  ${MUSERNAME_E1}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${MUSERNAME_E1}
    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id17}  ${msg1}  ${messageType[0]}  ${caption1}   ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id15}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id17}
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id15}
    Set Suite Variable  ${msgId2}  ${resp.json()[0]['messageId']}
    

JD-TC-User Consumer Communication-UH1
    [Documentation]  User communicate with consumer, using another Provider account
    ${resp}=  Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p_id}  ${p1_id}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_EXIST}"

JD-TC-User Consumer Communication-UH2
    [Documentation]  User communicate with consumer, using consumer login
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${cR_id15}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_NOT_EXIST}"


JD-TC-User Consumer Communication-UH3
    [Documentation]  User communicate with consumer, using invalid provider id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   000  ${cR_id15}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_NOT_EXIST}"


JD-TC-User Consumer Communication-UH4
    [Documentation]  User communicate with consumer, using invalid consumer id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p_id}  0000  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}

    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_EXIST}"


# JD-TC-User Consumer Communication-UH5
#     [Documentation]  User communicate with consumer without login
#     ${msg2}=   FakerLibrary.Word
#     ${resp}=  User Consumer Communication    ${p1_id}   ${cR_id15}  ${msg2}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    

JD-TC-User Consumer Communication-UH6
    [Documentation]  User communicate with consumer, using disabled user_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get User By Id  ${p1_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id15}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}

    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${PROVIDER_NOT_ACTIVE}"

    
JD-TC-User Consumer Communication-UH7
    [Documentation]  User communicate with consumer, using disabled user_id by consumer
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get User By Id  ${p1_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${p1_id}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}

    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${PROVIDER_NOT_ACTIVE}"

    


