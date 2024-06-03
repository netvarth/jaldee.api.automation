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
Resource          /ebs/TDD/AppKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py


*** Variables ***

@{emptylist} 
${self}         0
${parallel}     1
${capacity}     5
&{custom_web_headers}    Content-Type=application/json  BOOKING_REQ_FROM=CUSTOM_WEBSITE   website-link=https://jaldeehomeo.com
&{ioscons_headers}       Content-Type=application/json  User-Agent=iphone  BOOKING_REQ_FROM=CONSUMER_APP 
&{ios_sp_headers}        Content-Type=application/json  User-Agent=iphone  BOOKING_REQ_FROM=SP_APP  
&{andcons_headers}       Content-Type=application/json  User-Agent=android  BOOKING_REQ_FROM=CONSUMER_APP   
${tz}   Asia/Kolkata


***Test Cases***

JD-TC-ApplyLabelToService-1
    
    [Documentation]   Enable Channel for a provider by super admin(web_jaldee_homeo),
    ...    then apply channel label to a service.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

    clear_Label  ${PUSERNAME110}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

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
   
    ${channel_ids}=  Create List   ${channel_id1}   

    ${resp}=  Enable Disable Channel    ${account_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}   ${resp.json()[0]['id']}  

    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id2}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${label_ids}=  Create List   ${label_id} 

    ${resp}=  Apply Labels To Service    ${ser_id1}   ${label_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['leadTime']}               0


JD-TC-ApplyLabelToService-2
    
    [Documentation]   Enable Channel for a provider by super admin(web_jaldee_homeo),
    ...    then apply channel label to a service, then a jaldee consumer try to view that service..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId}  ${duration}  ${bool1}  ${ser_id1}  ${ser_id2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appmt Service By LocationId   ${locId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${ser_id2}
    Should Not Contain   ${resp.json()[0]}    ${ser_id1}


JD-TC-ApplyLabelToService-3
    
    [Documentation]   Enable Channel for a provider by super admin(web_jaldee_homeo),
    ...    then apply channel label to a service, then a jaldee consumer try to view that service in custom web..


    ${resp}=  App Consumer Login  ${custom_web_headers}  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  App Get Appmt Service By LocationId    ${custom_web_headers}  ${locId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${ser_id1}
    Should Not Contain   ${resp.json()[0]}    ${ser_id2}

    ${resp}=  App Consumer Logout  ${custom_web_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ApplyLabelToService-4
    
    [Documentation]   Enable Channel for a provider by super admin
    ...   (web_jaldee_homeo,android_jaldee_homeo,ios_jaldee_homeo), then apply label to a service
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    clear_Label  ${PUSERNAME160}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id2}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId1}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}    ${channel_id2}  ${channel_id3} 

    ${resp}=  Enable Disable Channel    ${account_id2}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id2}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id2}']}   ${channel_disname2}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id3}']}   ${channel_disname3}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}   ${resp.json()[0]['id']}  

    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id3}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}
 
    ${label_ids}=  Create List   ${label_id} 

    ${resp}=  Apply Labels To Service    ${ser_id3}   ${label_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['leadTime']}               0


JD-TC-ApplyLabelToService-5
    
    [Documentation]   Enable Channel for a provider by super admin
    ...   (web_jaldee_homeo,android_jaldee_homeo,ios_jaldee_homeo), then apply label to a service
    ...    then jaldee consumer can view service in respective channels only.

# ...... web jaldee homeo......

    ${resp}=  App Consumer Login  ${custom_web_headers}  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  App Get Appmt Service By LocationId   ${custom_web_headers}  ${locId1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${ser_id3}
    
    ${resp}=  App Consumer Logout  ${custom_web_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ...... android jaldee homeo......

    ${resp}=  App Consumer Login  ${andcons_headers}  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  App Get Appmt Service By LocationId   ${andcons_headers}   ${locId1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${ser_id3}
    
    ${resp}=  App Consumer Logout  ${andcons_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ...... ios jaldee homeo......

    ${resp}=  App Consumer Login  ${ioscons_headers}  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  App Get Appmt Service By LocationId   ${ioscons_headers}   ${locId1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${ser_id3}
    
    ${resp}=  App Consumer Logout  ${ioscons_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ApplyLabelToService-6
    
    [Documentation]   Disable one channel by sa.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}   

    ${resp}=  Enable Disable Channel    ${account_id2}  ${actiontype[1]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id2}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id2}']}   ${channel_disname2}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id3}']}   ${channel_disname3}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-ApplyLabelToService-7
    
    [Documentation]   Jaldee consumer try to get service in disabled channel.

# ...... web jaldee homeo......

    ${resp}=  App Consumer Login  ${custom_web_headers}  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  App Get Appmt Service By LocationId   ${custom_web_headers}  ${locId1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}     []
    
    ${resp}=  App Consumer Logout  ${custom_web_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ApplyLabelToService-8
    
    [Documentation]   Apply multiple labels to a service including jaldee homeo.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    clear_Label  ${PUSERNAME162}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id3}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId3}
    ELSE
        Set Suite Variable  ${locId3}  ${resp.json()[0]['id']}
    END

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}    ${channel_id2}  ${channel_id3} 

    ${resp}=  Enable Disable Channel    ${account_id3}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id3}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id2}']}   ${channel_disname2}
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id3}']}   ${channel_disname3}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence

    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id1}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id1}   ${resp.json()[0]['id']}  
    Set Test Variable  ${label_id2}   ${resp.json()[1]['id']}  
    Set Test Variable  ${label_Name2}   ${resp.json()[1]['label']}  

    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    Should Be Equal As Strings  ${resp.json()[1]['label']}        ${l_name[0]}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}  ${l_name[1]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}       ${Qstate[0]}

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id4}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId3}  ${duration}  ${bool1}  ${ser_id4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}
    
    ${label_name}=   Set variable   ${l_name[0]}
    ${label_ids}=  Create List   ${label_id1}   ${label_id2} 

    ${resp}=  Apply Labels To Service    ${ser_id4}   ${label_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['label']['${label_Name2}']}     ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['leadTime']}               0


JD-TC-ApplyLabelToService-9
    
    [Documentation]   Enable Channel for a multi user account by super admin(web_jaldee_homeo),
    ...    then apply channel label to a service in account level.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_Label  ${PUSERNAME110}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${maccount_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}   

    ${resp}=  Enable Disable Channel    ${maccount_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${maccount_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}   ${resp.json()[0]['id']}  

    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_ids}=  Create List   ${label_id} 

    ${resp}=  Apply Labels To Service    ${ser_id1}   ${label_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['leadTime']}               0


JD-TC-ApplyLabelToService-10
    
    [Documentation]   Enable Channel for a multi user account by super admin(web_jaldee_homeo),
    ...    then apply channel label to a service in user level.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_Label  ${PUSERNAME111}  

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${maccount_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${channel_ids}=  Create List   ${channel_id1}   

    ${resp}=  Enable Disable Channel    ${maccount_id1}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${maccount_id1}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}   ${resp.json()[0]['id']}  

    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}

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
            IF   not '${user_phone}' == '${PUSERNAME111}'
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

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${desc}=  FakerLibrary.sentence
    ${P1SERVICE1}=    FakerLibrary.word
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${P1SERVICE1}  ${desc}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_ids}=  Create List   ${label_id} 

    ${resp}=  Apply Labels To Service    ${ser_id1}   ${label_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['leadTime']}               0


JD-TC-ApplyLabelToService-11
    
    [Documentation]   Try to filter service with label-eq.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Service   labels-eq=${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()[0]['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['leadTime']}               0

JD-TC-ApplyLabelToService-12
    
    [Documentation]   Try to take appointment for that servies.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId}  ${duration}  ${bool1}  ${ser_id1} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}     apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CAN_NOT_BOOK_SERVICE_THIS_CHANNEL}

JD-TC-ApplyLabelToService-13
    
    [Documentation]   Try to take appointment for that servies.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
         
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  2  30   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=100
    Set Suite Variable   ${capacity}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CAN_NOT_BOOK_SERVICE_THIS_CHANNEL}
    
JD-TC-ApplyLabelToService-14
    
    [Documentation]   Try to get that servies from consumer side.

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service By Location   ${locId} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}        []
    