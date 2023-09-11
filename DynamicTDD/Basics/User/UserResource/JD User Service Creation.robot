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
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${SERVICE8}  Threading
${SERVICE9}  Threading12
${SERVICE10}  Threading13


***Test Cases***

JD-TC-ServiceForUser-1
     [Documentation]  Create  a service for a valid user
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+980217
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
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
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+666445
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin}=  get_pincode

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=20  max=50
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}

JD-TC-ServiceForUser-2
     [Documentation]  Create  a service for a valid user with service name same as another user
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+55662
     clear_users  ${PUSERNAME_U2}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
     ${pin1}=  get_pincode
     
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id1}  ${resp.json()}
     ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${dur}   notification=${bool[0]}   notificationType=${notifytype[0]}  totalAmount=${amt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${dep_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}


JD-TC-ServiceForUser -UH1
     [Documentation]   Provider create a service for a User without login      
     ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-ServiceForUser -UH2
    [Documentation]   Consumer  create a service for user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-ServiceForUser-UH3      
     [Documentation]  Create an already existing service
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  000
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_CANT_BE_SAME}"


JD-TC-ServiceForUser-4
     [Documentation]  Create a service for a branch, Create same service for valid user
     ...   Disable and Enable the branch and user service

     ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
     ${len}=   Split to lines  ${resp}
     ${length}=  Get Length   ${len}
     ${licId}  ${licname}=  get_highest_license_pkg
     FOR   ${a}  IN RANGE   0  ${length}
          ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
          Log  ${resp.json()}
          Should Be Equal As Strings    ${resp.status_code}    200

          ${decrypted_data}=  db.decrypt_data  ${resp.content}
          Log  ${decrypted_data}
          # Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
          Set Test Variable   ${pkgId}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
          ${domain}=   Set Variable    ${decrypted_data['sector']}
          ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

          clear_service   ${MUSERNAME${a}}
          # Set Test Variable   ${pkgId}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
          # ${domain}=   Set Variable    ${resp.json()['sector']}
          # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
          Run Keyword If  "${pkgId}"=="${licId}"  Exit For Loop
     END

     # clear_service   ${MUSERNAME28}

     ${resp}=  View Waitlist Settings
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp1}=   Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

     ${resp}=  Get Service
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Toggle Department Enable
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Departments 
     Log  ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200

     ${dep_name1}=  FakerLibrary.bs
     Set Suite Variable   ${dep_name1}
     ${dep_code1}=   Random Int  min=100   max=999
     Set Suite Variable   ${dep_code1}
     ${dep_desc1}=   FakerLibrary.word  
     Set Suite Variable    ${dep_desc1}
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${depid1}  ${resp.json()}

     ${resp}=  Get Department ById  ${depid1}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}

     ${SERVICE1}=    FakerLibrary.word
     Set Suite Variable  ${SERVICE1}
     ${desc}=   FakerLibrary.sentence
     ${servicecharge}=   Random Int  min=100  max=500
     ${ser_duratn}=      Random Int   min=10   max=30
     ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sid1}  ${resp.json()}

     ${resp}=  Get Service
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User Count
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
     ${ran int}=    Convert To Integer    ${ran int}
     ${B28_User1}=  Evaluate  ${PUSERNAME}+${ran int}
     clear_users  ${B28_User1}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${address1}=  get_address
     ${dob1}=  FakerLibrary.Date
     ${pin1}=  get_pincode

     ${subdomains}=   get_subdomains   ${domain}
     log    ${subdomains}
     ${sublen}=   Get Length  ${subdomains}
     ${i}=  Random Int  min=0  max=${sublen-1}
     ${sub_domain_id}=  Set Variable  ${subdomains[${i}]['subdomainId']}
     
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${B28_User1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${B28_User1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${B28_User1}  ${countryCodes[0]}  ${B28_User1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id1}  ${resp.json()}

     ${resp}=  Create Service For User  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}  ${u_id1}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_sid1}  ${resp.json()}

     ${resp}=   Get Service By Id  ${u_sid1}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${ser_duratn}   notification=${bool[0]}   notificationType=${notifytype[0]}   status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  department=${depid1}
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}

     ${resp}=  Disable service  ${sid1} 
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Enable service  ${sid1} 
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Disable service  ${u_sid1} 
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Enable service  ${u_sid1} 
     Should Be Equal As Strings  ${resp.status_code}  200


