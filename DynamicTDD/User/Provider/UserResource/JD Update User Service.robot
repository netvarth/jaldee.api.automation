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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

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


***Test Cases***
JD-TC-Update UserService-1
     [Documentation]  Create  a service for a valid user and update that user service
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+985218
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+667446
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin}=  get_pincode
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

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

JD-TC-Update UserService-2
     [Documentation]  Create  a service for a valid user and update service with service name same as another user
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+668447
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname2}=  FakerLibrary.name
     ${lastname2}=  FakerLibrary.last_name
     ${dob2}=  FakerLibrary.Date
     ${pin2}=  get_pincode
     
     ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}
     ${description}=  FakerLibrary.sentence
     ${dur}=  FakerLibrary.Random Int  min=20  max=50
     ${amt}=  FakerLibrary.Random Int  min=200  max=500
     ${amt}=  Convert To Number  ${amt}  1
     ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id3}  ${resp.json()}
     ${resp}=   Get Service By Id  ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id2}
     ${resp}=  Update Service For User   ${s_id3}   ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Get Service By Id  ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id2}

JD-TC-Update UserService-UH1
     [Documentation]  create a user service and update that service with new department id
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+55773
     clear_users  ${PUSERNAME_U3}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
     ${pin1}=  get_pincode
   
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id1}  ${resp.json()}
     ${dep_name1}=  FakerLibrary.bs
     ${dep_code1}=   Random Int  min=100   max=999
     ${dep_desc1}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${depid2}  ${resp.json()}
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


JD-TC-Update UserService-UH2

     [Documentation]  Update a user service name to  an already existing name
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${resp}=  Create Service For User  ${SERVICE5}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id5}  ${resp.json()}

     ${resp}=   Get Service By Id  ${s_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE5}  description=${description1}  serviceDuration=${dur1}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}

     ${resp}=  Update Service For User   ${s_id5}   ${SERVICE2}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}   ${u_id} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422  
     Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_CANT_BE_SAME}"

JD-TC-Update UserService-UH3
    [Documentation]   Consumer  update a service for user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Service For User   ${s_id5}   ${SERVICE2}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Update UserService-UH4
     [Documentation]   Provider create a service for a User without login      
     ${resp}=  Update Service For User   ${s_id5}   ${SERVICE2}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}    ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 



***comment***
JD-TC-Update UserService-UH5

     [Documentation]  Update a user service using invalid userid
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${resp}=  Create Service For User  ${SERVICE6}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id6}  ${resp.json()}

     ${resp}=   Get Service By Id  ${s_id6}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE6}  description=${description1}  serviceDuration=${dur1}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}

     ${resp}=  Update Service For User   ${s_id6}   ${SERVICE6}  ${description1}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt1}  ${bool[0]}  ${bool[0]}  ${dep_id}   000 
     Log  ${resp.json()}

     ${resp}=   Get Service By Id  ${s_id6}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200


     # Should Be Equal As Strings  ${resp.status_code}  422  
     # Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_CANT_BE_SAME}"









