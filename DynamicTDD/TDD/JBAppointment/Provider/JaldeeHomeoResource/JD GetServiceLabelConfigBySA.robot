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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***
@{emptylist}


***Test Cases***

JD-SA-TC-GetServiceLabelConfig-1
    
    [Documentation]   Get service label config.

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
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   