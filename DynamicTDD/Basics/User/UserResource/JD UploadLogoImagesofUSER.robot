
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




*** Test Cases ***

JD-TC-Upload Logo Image of USER-1
    [Documentation]   User upload logo image
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E1}=  Evaluate  ${PUSERNAME}+267906702
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E1}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_E1}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E1}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E1}${\n}
     Set Suite Variable  ${PUSERNAME_E1}
     ${id}=  get_id  ${PUSERNAME_E1}
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


    # ${number1}=  Random Int  min=1000  max=2000
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+872089
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode

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
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
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

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    # ${resp}=  pyproviderlogin  ${PUSERNAME_E1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  
    # # @{resp}=  uploadLogoImages 
    # # Should Be Equal As Strings  ${resp[1]}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  uploadLogoImagesofUSER   ${u_id1}
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${name}   ${resp[0]['keyName']}
    # Set Suite Variable  ${url}   ${resp[0]['url']}
    # Set Suite Variable  ${type}   ${resp[0]['type']}

    ${resp}=  uploadLogoImagesofUSER   ${u_id1}   ${cookie}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${name}  ${resp.json()['keyName']}
    Set Suite Variable  ${url}  ${resp.json()['url']} 
    Set Suite Variable  ${type}  ${resp.json()['type']}
    
    # sleep  05s 
    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo
    Should Be Equal As Strings  ${resp.json()['logo']['prefix']}  logo
    Should Be Equal As Strings  ${resp.json()['logo']['keyName']}  ${name}
    # Should Be Equal As Strings  ${resp.json()['logo']['url']}   ${url} 
    Should Be Equal As Strings  ${resp.json()['logo']['type']}  ${type}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Upload Logo Image of USER-UH1
    [Documentation]   Provider check to  Upload Logo image of USER
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${PUSERNAME_E1}
    # ${resp}=  pyproviderlogin  ${PUSERNAME_E1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  uploadLogoImagesofUSER   ${p_id}     
    # Should Be Equal As Strings  ${resp[1]}  422
    # Should Be Equal As Strings  ${resp[0]}   ${INVALID_PROVIDER_ID}

    ${resp}=  uploadLogoImagesofUSER   ${p_id}   ${cookie}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Upload Logo Image of USER-UH2
    [Documentation]   Upload Logo image of USER without login  
    # @{resp}=  uploadLogoImagesofUSER   ${u_id1}     
    # Should Be Equal As Strings  ${resp[1]}  419
    # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}

    ${empty_cookie}=  Create Dictionary
    ${resp}=  uploadLogoImagesofUSER   ${u_id1}   ${empty_cookie}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Upload Logo Image of USER-UH3
    [Documentation]   Consumer check to Upload Logo image of USER
    # ${resp}=  Pyconsumerlogin  ${CUSERNAME1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  uploadLogoImagesofUSER   ${u_id1}
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL} 
    ${resp}=  uploadLogoImagesofUSER   ${u_id1}   ${cookie}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"



JD-TC-Upload Logo Image of USER-UH4
    [Documentation]   User Upload Logo image without creating user profile
    ${resp}=  Encrypted Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${PUSERNAME43}
    # ${resp}=  pyproviderlogin  ${PUSERNAME43}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  uploadLogoImagesofUSER   ${u_id2}   ${cookie}  
    # Should Be Equal As Strings  ${resp[1]}  422
    # Should Be Equal As Strings  ${resp[0]}   ${INVALID_PROVIDER_ID}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


