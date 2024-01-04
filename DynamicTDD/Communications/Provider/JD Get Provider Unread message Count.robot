*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communications
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}     Smoothening11
${SERVICE2}     Smoothening22
${SERVICE3}     PHONES
${SERVICE4}     PHONE
${queue1}       Queue1
${queue2}       Queue2
${sTime}        08:15 AM
${eTime}        07:15 PM
${longi}          89.524764
${latti}          89.259874

*** Test Cases ***

JD-TC-Get Unread Message Count-INDEPENDENT_SP-1
    [Documentation]  Get Provider Unread Message Count
    ${a_id}=  get_acc_id  ${PUSERNAME6}
    clear_Providermsg  ${PUSERNAME6}
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME1}
    ${msg}=  FakerLibrary.text
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    # ${resp}=  General Communication with Provider   ${msg}   ${a_id}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${a_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Unread Message Count-INDEPENDENT_SP-2
    [Documentation]  Get Provider Unread Message Count
    ${a_id}=  get_acc_id  ${PUSERNAME6}
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME1}
    ${msg}=  FakerLibrary.text
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    # ${resp}=  General Communication with Provider   ${msg}   ${a_id}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${a_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Get Unread Message Count-INDEPENDENT_SP-3
	[Documentation]   Get Unread message count after Communication Between Consumer and Provider after waitlist
	${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue      ${PUSERNAME7}
    clear_location   ${PUSERNAME7}
    clear_service    ${PUSERNAME7}
    clear waitlist   ${PUSERNAME7}
    clear_Providermsg  ${PUSERNAME7}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}

    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

   
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}


    Set Suite Variable  ${cid}
    ${aid}=  get_acc_id  ${PUSERNAME7}
    Set Suite Variable  ${aid}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${aid}   ${wid}   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Unread Message Count-INDEPENDENT_SP-4
    [Documentation]  Get Provider unread message count after get communication by provider
    ${a_id}=  get_acc_id  ${PUSERNAME8}
    clear_Providermsg  ${PUSERNAME8}
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}
    clear_Providermsg  ${PUSERNAME8}
    ${msg8}=  FakerLibrary.text
    Set Suite Variable  ${msg8}
    ${caption8}=  Fakerlibrary.sentence
    Set Suite Variable  ${caption8}
    # ${resp}=  General Communication with Provider   ${msg8}   ${a_id}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${a_id}  ${msg8}  ${messageType[0]}  ${caption8}   ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id8}  ${decrypted_data['id']}
    # Set Test Variable  ${p_id8}  ${resp.json()['id']}
    ${account_id1}=  get_acc_id  ${PUSERNAME8}
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg8}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   0
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}



    ${resp}=  Reading Consumer Communications  ${c_id}  ${msgId1}   0 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0

    
JD-TC-Get Unread Message Count-UH1
    [Documentation]   Get unread message count without login
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  419          
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Get Unread Message Count-UH2
    [Documentation]  consumer login to access the get unread message count URL 
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-Verify Get Unread Message Count-INDEPENDENT_SP-3
    [Documentation]   verification of Get Unread message count after Communication Between Consumer and Provider after waitlist
    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id1}=  get_acc_id  ${PUSERNAME7}
    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c1_id}=  get_id  ${CUSERNAME1}
    ${msg7}=  FakerLibrary.sentence
    Set Suite Variable  ${msg7}
    ${caption7}=  Fakerlibrary.sentence
    Set Suite Variable  ${caption7}
    # ${resp}=  General Communication with Provider   ${msg7}   ${aid}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${aid}  ${msg7}  ${messageType[0]}  ${caption7}   ${EMPTY}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id7}  ${decrypted_data['id']}
    # Set Test Variable  ${p_id7}  ${resp.json()['id']}

    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  2  accountId=${account_id1}  msg=${msg7}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}    ${c1_id}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}  0  
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}

    ${resp}=  Reading Consumer Communications  ${c1_id}  ${msgId1}-${msgId2}    0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get provider Unread message Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1







JD-TC-Get Unread Message Count-BRANCH-5
    [Documentation]  Get Provider unread message count after Communication of a User with a consumer
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+40333907
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
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E1}${\n}
    Set Suite Variable  ${MUSERNAME_E1}
    ${id}=  get_id  ${MUSERNAME_E1}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
  
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
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime}
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # Set Suite Variable   ${eTime}
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  30
    # ${sTime}=  db.subtract_timezone_time  ${tz}  0  05
    Set Suite Variable  ${BsTime30}  ${sTime}
    # ${eTime}=  db.subtract_timezone_time  ${tz}  1  00
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable  ${BeTime30}  ${eTime}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${resp}=  Update Business Profile With Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable  ${state}
    
    # ${number1}=  Random Int  min=1000  max=2000
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+44333097
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERNAME_U1}+405241
    ${tlgnum}=  Evaluate  ${PUSERNAME_U1}+405142

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    # ${number2}=  Random Int  min=2500  max=3500
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+8822087
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    ${pin2}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERNAME_U2}+405241
    ${tlgnum}=  Evaluate  ${PUSERNAME_U2}+405142

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}



    ${cR_id1}=  get_id  ${CUSERNAME8}
    Set Suite Variable  ${cR_id1}  ${cR_id1}
    clear_Consumermsg  ${CUSERNAME8}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pR_id1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pR_id1}  ${resp.json()['id']}
    ${account_id1}=  get_acc_id  ${MUSERNAME_E1}
    Set Suite Variable  ${account_id1}

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
    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id1}  ${msg1}  ${messageType[0]}  ${caption1}   ${EMPTY} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  User Consumer Communication    ${p1_id}  ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    # ${resp}=  User Consumer Communication    ${p2_id}   ${cR_id1}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p2_id}  ${cR_id1}  ${msg2}  ${messageType[0]}  ${caption2}   ${EMPTY} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    
    Verify Response List  ${resp}  1  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    ${p2_id}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  2
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Reading Provider Communications  ${pR_id1}  ${account_id1}  ${msgId1} 
    ${resp}=  Reading Provider Communications  ${p1_id}  ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Reading Provider Communications  ${pR_id1}  ${account_id1}  ${msgId2}
    ${resp}=  Reading Provider Communications  ${p2_id}  ${account_id1}  ${msgId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Consumermsg  ${CUSERNAME8} 
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Get Unread Message Count-BRANCH-6
    [Documentation]  Get Provider unread message count after Communication of a User with multiple number of consumers
    ${cR_id5}=  get_id  ${CUSERNAME5}
    ${cR_id7}=  get_id  ${CUSERNAME7}
    clear_Consumermsg  ${CUSERNAME7}
    clear_Consumermsg  ${CUSERNAME5}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${MUSERNAME_E1}
    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    # ${resp}=  User Consumer Communication    ${p1_id}   ${cR_id7}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id7}  ${msg1}  ${messageType[0]}  ${caption1}   ${EMPTY} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    # ${resp}=  User Consumer Communication    ${p1_id}   ${cR_id5}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id5}  ${msg2}  ${messageType[0]}  ${caption2}   ${EMPTY} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id7}
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  ${p1_id}   ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id5}
    Set Suite Variable  ${msgId2}  ${resp.json()[0]['messageId']}
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  ${p1_id}   ${account_id1}  ${msgId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200





    