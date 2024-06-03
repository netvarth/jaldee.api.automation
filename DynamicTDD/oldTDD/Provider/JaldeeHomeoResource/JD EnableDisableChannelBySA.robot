*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions 
Force Tags        Jaldee Homeo
Library           Collections
Library           String
Library           json
Library           FakerLibrary  
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py


*** Variables ***
@{emptylist}


***Test Cases***

JD-SA-TC-EnableDisableChannel-1
    
    [Documentation]   Enable Channel for a provider by super admin(web_jaldee_homeo,android_jaldee_homeo,ios_jaldee_homeo).

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    clear_Label  ${PUSERNAME100}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service Label Config   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${channel_id1}   ${resp.json()[0]['id']}  
    Set Suite Variable  ${channel_id2}   ${resp.json()[1]['id']} 
    Set Suite Variable  ${channel_id3}   ${resp.json()[2]['id']} 

    Set Suite Variable  ${channel_name1}   ${resp.json()[0]['name']}  
    Set Suite Variable  ${channel_name2}   ${resp.json()[1]['name']} 
    Set Suite Variable  ${channel_name3}   ${resp.json()[2]['name']} 

    Set Suite Variable  ${channel_disname1}   ${resp.json()[0]['displayName']}  
    Set Suite Variable  ${channel_disname2}   ${resp.json()[1]['displayName']} 
    Set Suite Variable  ${channel_disname3}   ${resp.json()[2]['displayName']} 

    Set Suite Variable  ${label_id1}   ${resp.json()[0]['serviceLabels'][0]['id']}  
    Set Suite Variable  ${label_id2}   ${resp.json()[1]['serviceLabels'][0]['id']}  
    Set Suite Variable  ${label_id3}   ${resp.json()[2]['serviceLabels'][0]['id']}  
   
    Set Suite Variable  ${label_name1}   ${resp.json()[0]['serviceLabels'][0]['name']}  
    Set Suite Variable  ${label_name2}   ${resp.json()[1]['serviceLabels'][0]['name']}  
    Set Suite Variable  ${label_name3}   ${resp.json()[2]['serviceLabels'][0]['name']}  
    
    Set Suite Variable  ${label_disname1}   ${resp.json()[0]['serviceLabels'][0]['displayName']}  
    Set Suite Variable  ${label_disname2}   ${resp.json()[1]['serviceLabels'][0]['displayName']}  
    Set Suite Variable  ${label_disname3}   ${resp.json()[2]['serviceLabels'][0]['displayName']}  
   

    ${channel_ids}=  Create List   ${channel_id1}   ${channel_id2}  ${channel_id3}

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id2}']}   ${channel_disname2}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id3}']}   ${channel_disname3}
    
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

JD-SA-TC-EnableDisableChannel-2
    
    [Documentation]   Disable Channel for a provider by super admin(web_jaldee_homeo).

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    clear_Label  ${PUSERNAME101}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List    ${channel_id1}  

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
    Should Not Contain    ${resp.json()}    ${channel_disname2}   

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}  

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[1]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[1]}

JD-SA-TC-EnableDisableChannel-3
    
    [Documentation]   Enable Channel for a multi user account by super admin(web_jaldee_homeo).

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    clear_Label  ${PUSERNAME99}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}  

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp} =  Get Account Id  ${account_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

JD-SA-TC-EnableDisableChannel-UH1
    
    [Documentation]   Enable Channel for a user by super admin(web_jaldee_homeo).

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_Label  ${PUSERNAME100}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME100}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}   

    ${resp}=  Enable Disable Channel    ${u_id}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

JD-SA-TC-EnableDisableChannel-UH2
    
    [Documentation]   Enable Channel for a provider by super admin(web_jaldee_homeo) without giving any channel ids.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      []


JD-SA-TC-EnableDisableChannel-UH3
    
    [Documentation]   Enable Channel for a provider by super admin with invalid account id.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List  ${channel_id1}     ${channel_id2}    

    ${invacc_id1}=   Random Int   min=1000   max=5000
    ${resp}=  Enable Disable Channel    ${invacc_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-SA-TC-EnableDisableChannel-UH4
    
    [Documentation]   Enable Channel for a provider by super admin(web_jaldee_homeo) which is already enabled.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_Label  ${PUSERNAME102}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}    

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${CHANNEL_ALREADY_ENABLED}=  Format String   ${CHANNEL_ALREADY_ENABLED}   ${channel_name1}
   
    ${channel_ids}=  Create List   ${channel_id1}    

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CHANNEL_ALREADY_ENABLED}



JD-SA-TC-EnableDisableChannel-UH5
    
    [Documentation]   Disable Channel for a provider by super admin(web_jaldee_homeo) which is already disabled.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_Label  ${PUSERNAME123}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}    

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${CHANNEL_ALREADY_DISABLED}=  Format String   ${CHANNEL_ALREADY_DISABLED}   ${channel_name1}
   
    ${channel_ids}=  Create List   ${channel_id1}    

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[1]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[1]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CHANNEL_ALREADY_DISABLED}