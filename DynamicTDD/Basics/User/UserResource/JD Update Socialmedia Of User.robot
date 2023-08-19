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


***Test Cases***

JD-TC-UserSocialMedia-1
     [Documentation]  Update user social media info
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+770219
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
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+116445
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin1}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}   bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
     
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

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${fb}=  Create SocialMedia  facebook  https://facebook.com/netvarth
    ${tw}=  Create SocialMedia  twitter  https://twitter.com/netvarth
    ${yt}=  Create SocialMedia  youtube  https://youtube.com/netvarth     
    Set Suite Variable  ${fb}
    Set Suite Variable  ${tw}
    Set Suite Variable  ${yt} 
    ${resp}=  Update SocialMedia Of User  ${u_id}   ${fb}  ${tw}  ${yt}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['socialMedia']} 
    Should Be Equal As Integers  ${count}  3
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['resource']}  facebook  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['value']}  https://facebook.com/netvarth
    Should Be Equal As Strings  ${resp.json()['socialMedia'][1]['resource']}  twitter  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][1]['value']}   https://twitter.com/netvarth
    Should Be Equal As Strings  ${resp.json()['socialMedia'][2]['resource']}  youtube  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][2]['value']}  https://youtube.com/netvarth

JD-TC-UserSocialMedia-2
    [Documentation]  Update social media info of a user without any field
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Update SocialMedia Of User  ${u_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['socialMedia']} 
    Should Be Equal As Integers  ${count}  0
    Should Be Equal As Strings  ${resp.json()['socialMedia']}  []

JD-TC-UserSocialMedia-3
    [Documentation]  Update social media info of a user by one field
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${fb}=  Create SocialMedia  facebook  https://facebook.com/Jaldee    
    ${resp}=  Update SocialMedia Of User  ${u_id}   ${fb}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['socialMedia']} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['resource']}  facebook  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['value']}  https://facebook.com/Jaldee 

JD-TC-UserSocialMedia -UH1
     [Documentation]   Provider Update social media of a User without login      
     ${resp}=  Update SocialMedia Of User  ${u_id}   ${fb} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UserSocialMedia -UH2
    [Documentation]   Consumer Update social media of a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update SocialMedia Of User  ${u_id}   ${fb} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UserSocialMedia-UH3
     [Documentation]  Update social media of a user with invalid id by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Update SocialMedia Of User  000   ${fb} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"
