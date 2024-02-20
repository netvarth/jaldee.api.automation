
*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Remove File  cookies.txt
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


*** Test Cases ***

JD-TC-Delete Logo Image of USER-1
    [Documentation]   User Delete logo image

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+18908901
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

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+70077007
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Suite Variable  ${pin1}

    ${number2}=  Random Int  min=2500  max=3500
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    ${pin2}=  get_pincode
    Set Suite Variable  ${pin2}
    ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${employee_id2}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id2}

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  

    ${resp}=  uploadLogoImagesofUSER   ${u_id1}   ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${name}  ${resp.json()['keyName']}
    Set Test Variable  ${url}   ${resp.json()['url']} 
    Set Test Variable  ${type}   ${resp.json()['type']}


    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['logo']['prefix']}  logo
    Should Be Equal As Strings  ${resp.json()['logo']['keyName']}  ${name}
    Should Be Equal As Strings  ${resp.json()['logo']['type']}  ${type}
   #Should Be Equal As Strings  ${resp.json()['logo']['url']}   ${url} 
    

    ${resp}=  deleteUserLogo  ${u_id1}  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Not Contain  ${resp.json()}   ${name}


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Delete Logo Image of USER-UH1
    [Documentation]   Provider check to  Delete Logo image of USER
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  deleteUserLogo  ${p_id}  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${INVALID_PROVIDER_ID}"

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Delete Logo Image of USER-UH2
    [Documentation]   Delete Logo image of USER without login
    
    ${empty_cookie}=  Create Dictionary
    ${resp}=  deleteUserLogo  ${u_id1}  ${name}  ${empty_cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-Delete Logo Image of USER-UH3
    [Documentation]   Consumer check to Delete Logo image of USER
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  deleteUserLogo  ${u_id1}  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Delete Logo Image of USER-UH4
    [Documentation]   User u_id2 Delete Logo image of another user u_id1, after creating user profile
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec1}=  get_specs  ${resp.json()}
    Log  ${spec1}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages1}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages1}

    ${bs1}=  FakerLibrary.bs
    ${bs_des1}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs1}  ${bs_des1}  ${spec1}  ${Languages1}  ${sub_domain_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id2}  ${resp.json()['profileId']}
    ${resp}=  Get User Profile  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  uploadLogoImagesofUSER   ${u_id1}   ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${name1}  ${resp.json()['keyName']}
    Set Test Variable  ${url2}    ${resp.json()['url']} 
    Set Test Variable  ${type1}  ${resp.json()['type']}

    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['logo']['prefix']}  logo
    Should Be Equal As Strings  ${resp.json()['logo']['keyName']}  ${name1}
     Should Be Equal As Strings  ${resp.json()['logo']['type']}  ${type1}
   #  Should Be Equal As Strings  ${resp.json()['logo']['url']}    ${url2} 
   

    ${resp}=  Get User Profile  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  deleteUserLogo  ${u_id2}  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.content}  ${LOGIN_NO_ACCESS_FOR_URL}
    
    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['logo']['prefix']}  logo
    Should Be Equal As Strings  ${resp.json()['logo']['keyName']}  ${name1}
   # Should Be Equal As Strings  ${resp.json()['logo']['url']}   ${url2} 
    Should Be Equal As Strings  ${resp.json()['logo']['type']}  ${type1}

*** Comments ***

JD-TC-Delete Logo Image of USER-UH5
    [Documentation]   User Delete Logo image without creating user profile
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
    ${resp}=  pyproviderlogin  ${MUSERNAME_E1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp}  200

    @{resp}=  uploadLogoImagesofUSER   ${u_id1}
    Should Be Equal As Strings  ${resp[1]}  200
    Set Suite Variable  ${name1}   ${resp[0]['keyName']}

    ${resp}=  DeleteLogoImageofUSER  ${u_id2}  ${name1}
    Should Be Equal As Strings  ${resp[1]}  422
    Should Be Equal As Strings  ${resp[0]}   ${INVALID_PROVIDER_ID}
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



