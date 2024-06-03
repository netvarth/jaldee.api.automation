***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${SERVICE1}     Henna
${SERVICE2}     Hair color
${SERVICE3}     foundation   
${SERVICE4}     pedicure
${SERVICE5}     manicure
${SERVICE6}     Hair wash
${SERVICE7}     Hair cleanig
${SERVICE8}     Hair spa
${SERVICE9}     nail art
${SERVICE10}    Golden facial
@{emptylist} 


***Test Cases***
JD-TC-UpdateServiceByUserLogin-1

       [Documentation]  Create  a service for a valid user and update that user service
#      ${iscorp_subdomains}=  get_iscorp_subdomains  1
#      Log  ${iscorp_subdomains}
#      Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
#      Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
#      Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
#      ${firstname_A}=  FakerLibrary.first_name
#      Set Suite Variable  ${firstname_A}
#      ${lastname_A}=  FakerLibrary.last_name
#      Set Suite Variable  ${lastname_A}
#      ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+985318
#      ${highest_package}=  get_highest_license_pkg
#      ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
#      Log  ${resp.json()}
#      Should Be Equal As Strings    ${resp.status_code}    200
#      ${resp}=  Account Activation  ${PUSERNAME_E}  0
#      Log   ${resp.json()}
#      Should Be Equal As Strings    ${resp.status_code}    200
#      ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
#      Should Be Equal As Strings    ${resp.status_code}    200
#      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
#      Log  ${resp.json()}
#      Should Be Equal As Strings    ${resp.status_code}    200
#      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
#      Set Suite Variable  ${PUSERNAME_E}
#      ${id}=  get_id  ${PUSERNAME_E}
#      Set Suite Variable  ${id}
#      ${bs}=  FakerLibrary.bs
#      Set Suite Variable  ${bs}
#      ${resp}=  Toggle Department Enable
#      Log   ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      sleep  2s
#      ${resp}=  Get Departments
#      Log   ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
#      ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+667446
#      clear_users  ${PUSERNAME_U1}
#      Set Suite Variable  ${PUSERNAME_U1}
#      ${firstname}=  FakerLibrary.name
#      Set Suite Variable  ${firstname}
#      ${lastname}=  FakerLibrary.last_name
#      Set Suite Variable  ${lastname}
#      ${dob}=  FakerLibrary.Date
#      Set Suite Variable  ${dob}
#      ${pin}=  get_pincode
     
#      ${u_id}=  Create Sample User
#     Set Suite Variable  ${u_id}
#     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
#     Should Be Equal As Strings  ${resp[0].status_code}  200
#     Should Be Equal As Strings  ${resp[1].status_code}  200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD} 
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${p_id1}=  get_acc_id  ${HLPUSERNAME2}
     Set Suite Variable   ${p_id1}
     reset_user_metric  ${p_id1}

     ${resp}=    Get Locations
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF   '${resp.content}' == '${emptylist}'
          ${locId1}=  Create Sample Location
          Set Suite Variable  ${locId1}
          ${resp}=   Get Location ById  ${locId1}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
          Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
     ELSE
          Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
          Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
     END

     ${resp}=   Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

     ${resp}=  View Waitlist Settings
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
     Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${dep_name1}=  FakerLibrary.bs
     ${dep_code1}=   Random Int  min=100   max=999
     ${dep_desc1}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable   ${dep_id}   ${resp.json()}

     ${u_id}=  Create Sample User
     Set Suite Variable  ${u_id}

     ${resp}=  Get User By Id      ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}


     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.status_code}  200

     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${description}=  FakerLibrary.sentence
     ${dur}=  FakerLibrary.Random Int  min=20  max=50
     ${amt}=  FakerLibrary.Random Int  min=200  max=500
     ${amt}=  Convert To Number  ${amt}  1
     ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id}  ${resp.json()}
     ${resp}=   Get Service By Id  ${s_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     ${description1}=  FakerLibrary.sentence
     Set Suite Variable  ${description1}
     ${dur1}=  FakerLibrary.Random Int  min=20  max=50
     Set Suite Variable  ${dur1}
     ${amt1}=  FakerLibrary.Random Int  min=200  max=500
     ${amt1}=  Convert To Number  ${amt1}  1
     Set Suite Variable  ${amt1}
     ${resp}=  Update Service For User   ${s_id}   ${SERVICE2}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Get Service By Id  ${s_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE2}  description=${description1}  serviceDuration=${dur1}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}

JD-TC-UpdateServiceByUserLogin-2
     [Documentation]  Create  a service for a valid user and update service with service name same as another user

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
      ${u_id1}=  Create Sample User
     Set Suite Variable  ${u_id1}

     ${resp}=  Get User By Id        ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Suite Variable      ${PUSERNAME_U2}     ${resp.json()['mobileNo']}
     
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
     Should Be Equal As Strings  ${resp.status_code}  200

     @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${description}=  FakerLibrary.sentence
     ${dur}=  FakerLibrary.Random Int  min=20  max=50
     ${amt}=  FakerLibrary.Random Int  min=200  max=500
     ${amt}=  Convert To Number  ${amt}  1
     ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id3}  ${resp.json()}
     ${resp}=   Get Service By Id  ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}
     ${resp}=  Update Service For User   ${s_id3}   ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Get Service By Id  ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}

JD-TC-UpdateServiceByUserLogin-UH1
     [Documentation]  create a user service and update that service with new department id

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+558130
     clear_users  ${PUSERNAME_U3}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
     ${pin1}=  get_pincode
   
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id1}  ${resp.json()}
     ${dep_name1}=  FakerLibrary.bs
     ${dep_code1}=   Random Int  min=100   max=999
     ${dep_desc1}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${depid2}  ${resp.json()}

     ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
     Should Be Equal As Strings  ${resp.status_code}  200

     @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Create Service For User  ${SERVICE10}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id10}  ${resp.json()}

     ${resp}=   Get Service By Id  ${s_id10}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE10}  description=${description1}  serviceDuration=${dur1}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}
  
     ${resp}=  Update Service For User   ${s_id10}   ${SERVICE10}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id2}   ${u_id1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"   "${CANT_CHANGE_USER_DEPT}"


JD-TC-UpdateServiceByUserLogin-UH2

     [Documentation]  Update a user service name to  an already existing name
     
     ${resp}=   Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD} 
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${resp}=  Get User
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     IF   not '${resp.content}' == '${emptylist}'
         ${len}=  Get Length  ${resp.json()}
          FOR   ${i}  IN RANGE   0   ${len}
          
          Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
               IF   not '${user_phone}' == '${HLPUSERNAME2}'
               clear_users  ${user_phone}
               END
          END
     END

     ${u_id5}=  Create Sample User
     Set Suite Variable  ${u_id5}

     ${resp}=  Get User By Id        ${u_id5}
     Log   ${resp.json()}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Suite Variable      ${PUSERNAME_U5}     ${resp.json()['mobileNo']}
     
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.status_code}  200

     @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

    
     ${resp}=  Create Service For User  ${SERVICE5}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id5}  ${resp.json()}

     ${resp}=   Get Service By Id  ${s_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE5}  description=${description1}  serviceDuration=${dur1}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id5}

     ${resp}=  Update Service For User   ${s_id5}   ${SERVICE5}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}   ${u_id5} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Should Be Equal As Strings  ${resp.status_code}  422  
     # Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_CANT_BE_SAME}"

JD-TC-UpdateServiceByUserLogin-UH3

    [Documentation]   Consumer  update a service for user

    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Service For User   ${s_id}   ${SERVICE2}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateServiceByUserLogin-UH4

     [Documentation]   Provider create a service for a User without login    

     ${resp}=  Update Service For User   ${s_id}   ${SERVICE2}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}    ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"










