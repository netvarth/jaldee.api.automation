*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Waitlist  Label
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}  SERVICE1 
${SERVICE2}  SERVICE2
${SERVICE3}  SERVICE3
${SERVICE4}  SERVICE4
${SERVICE5}  SERVICE5
${self}     0
${digits}       0123456789
&{Emptydict}
@{provider_list}
${start}              60  


***Keywords***

Billable 
    [Arguments]  ${min}=0   ${max}=260
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${min}   ${max}    
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  View Waitlist Settings
	      Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp2.status_code}    200
        ${pkg_id}=   get_highest_license_pkg
        Log   ${pkg_id}
        Set Suite Variable     ${pkg_id[0]}   ${pkg_id[0]}
        ${resp3}=  Get Business Profile
        Log   ${resp3.json()}
        Should Be Equal As Strings  ${resp3.status_code}  200
        Set Suite Variable   ${check1}   ${resp3.json()['licensePkgID']}
        Set Suite Variable   ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword If    '${check}' == 'True' and '${check1}' == '${pkg_id[0]}'   Append To List   ${provider_list}   ${PUSERNAME${a}}
    END
    [Return]  ${provider_list}


*** Test Cases ***
JD-TC-AddWaitlistLabel-1
    [Documentation]  Add label to Waitlist to Today's Checkin
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${billable_providers}=    Billable   
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_waitlist  ${billable_providers[7]}
    clear_location  ${billable_providers[7]}
    clear_customer   ${billable_providers[7]}
    clear_service   ${billable_providers[7]}
    clear_queue   ${billable_providers[7]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}   
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${s_id1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${s_id2}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  3  00   
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id1}  ${s_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid1} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


    clear_Label  ${billable_providers[7]}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}

    Set Suite Variable  ${lblname_1}  ${labelname[0]}
    Set Suite Variable  ${lbl_value_1}  ${label_value}

    ${resp}=  Add Label for Waitlist   ${wid1}  ${lblname_1}  ${lbl_value_1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_lbl1}=    Create Dictionary  ${labelname[0]}=${lbl_value_1}
    Set Suite Variable  ${label_lbl1}

      ${resp}=  Get Waitlist By Id  ${wid1} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  ynwUuid=${wid1}  waitlistStatus=${wl_status[1]}  label=${label_lbl1}



JD-TC-AddWaitlistLabel-2
    [Documentation]  Add label to Waitlist to Future day Checkin
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${Future_Day}=  db.add_timezone_date  ${tz}  5  
      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${que_id1}  ${Future_Day}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid_F1}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid_F1} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${Future_Day}  waitlistStatus=${wl_status[0]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # Set Suite Variable  ${lblname_1}  ${lblname[0]}
    # Set Suite Variable  ${lbl_value_1}  ${label_value}

    ${resp}=  Add Label for Waitlist   ${wid_F1}  ${lblname_1}  ${lbl_value_1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid_F1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid_F1}  waitlistStatus=${wl_status[0]}  label=${label_lbl1}

JD-TC-AddWaitlistLabel-3
    [Documentation]  give label value as integer

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_waitlist  ${billable_providers[7]}
    clear_location  ${billable_providers[7]}
    clear_customer   ${billable_providers[7]}
    clear_service   ${billable_providers[7]}
    clear_queue   ${billable_providers[7]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}   
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  3  00   
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid3}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid3} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


    
    clear_Label  ${billable_providers[7]}
    # ${Values}=  FakerLibrary.Words  	nb=3
    ${Values}=    Evaluate    random.sample(range(1, 10), 3)    random
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    # ${labelname}=    Evaluate    random.sample(range(1, 10), 2)    random
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value3}=   Set Variable   ${ValueSet[${i}]['value']}

    ${resp}=  Add Label for Waitlist   ${wid3}  ${labelname[0]}  ${label_value3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lblvalue3}=  Convert To String  ${label_value3}
    ${label3}=    Create Dictionary  ${labelname[0]}=${lblvalue3}

      ${resp}=  Get Waitlist By Id  ${wid3} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  ynwUuid=${wid3}  waitlistStatus=${wl_status[1]}  label=${label3}
   


JD-TC-AddWaitlistLabel-4
    [Documentation]  Remove Waitlist label and add the same label again.
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

   

    clear_waitlist  ${billable_providers[7]}
    clear_location  ${billable_providers[7]}
    clear_customer   ${billable_providers[7]}
    clear_service   ${billable_providers[7]}
    clear_queue   ${billable_providers[7]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   



    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}   
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  3  00   
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid4}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid4} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    
    clear_Label  ${billable_providers[7]}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value4}=   Set Variable   ${ValueSet[${i}]['value']}
    ${resp}=  Add Label for Waitlist   ${wid4}  ${labelname[0]}  ${label_value4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value4}

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid4}  waitlistStatus=${wl_status[1]}  label=${label}


    ${resp}=  Remove Waitlist Label   ${wid4}  ${labelname[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid4}  waitlistStatus=${wl_status[1]}  label=${Emptydict}

    ${resp}=  Add Label for Waitlist   ${wid4}  ${labelname[0]}  ${label_value4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid4}  waitlistStatus=${wl_status[1]}  label=${label}

 

    
JD-TC-AddWaitlistLabel-5
    [Documentation]  Add multiple label to Waitlist
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    clear_waitlist  ${billable_providers[7]}
    clear_location  ${billable_providers[7]}
    clear_customer   ${billable_providers[7]}
    clear_service   ${billable_providers[7]}
    clear_queue   ${billable_providers[7]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}   
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  3  00   
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid5}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid5} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    


    clear_Label  ${billable_providers[7]}
    ${Values1}=  FakerLibrary.Words  	nb=3
    ${ShortValues1}=  FakerLibrary.Words  	nb=3
    ${Notifmsg1}=  FakerLibrary.Words  	nb=3
    ${ValueSet1}=  Create ValueSet For Label  ${Values1[0]}  ${ShortValues1[0]}  ${Values1[1]}  ${ShortValues1[1]}  ${Values1[2]}  ${ShortValues1[2]}
    ${NotificationSet1}=  Create NotificationSet For Label  ${Values1[0]}  ${Notifmsg1[0]}  ${Values1[1]}  ${Notifmsg1[1]}  ${Values1[2]}  ${Notifmsg1[2]}
    ${labelname1}=  FakerLibrary.Words  nb=2
    ${label_desc1}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname1[0]}  ${labelname1[1]}  ${label_desc1}  ${ValueSet1}  ${NotificationSet1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id1}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id1}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname1[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname1[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc1}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values1[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues1[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values1[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues1[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values1[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues1[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values1[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg1[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values1[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg1[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values1[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg1[2]}
    

    ${len}=  Get Length  ${ValueSet1}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value1}=   Set Variable   ${ValueSet1[${i}]['value']}


    ${resp}=  Add Label for Waitlist   ${wid5}  ${labelname1[0]}  ${label_value1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label1}=    Create Dictionary  ${labelname1[0]}=${label_value1}

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid5}  waitlistStatus=${wl_status[1]}  label=${label1}


    ${Values2}=  FakerLibrary.Words  	nb=3
    ${ShortValues2}=  FakerLibrary.Words  	nb=3
    ${Notifmsg2}=  FakerLibrary.Words  	nb=3
    ${ValueSet2}=  Create ValueSet For Label  ${Values2[0]}  ${ShortValues2[0]}  ${Values2[1]}  ${ShortValues2[1]}  ${Values2[2]}  ${ShortValues2[2]}
    ${NotificationSet2}=  Create NotificationSet For Label  ${Values2[0]}  ${Notifmsg2[0]}  ${Values2[1]}  ${Notifmsg2[1]}  ${Values2[2]}  ${Notifmsg2[2]}
    ${labelname2}=  FakerLibrary.Words  nb=2
    ${label_desc2}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname2[0]}  ${labelname2[1]}  ${label_desc2}  ${ValueSet2}  ${NotificationSet2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id2}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  id=${label_id2}  label=${labelname2[0]}   displayName=${labelname2[1]}  description=${label_desc2}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values2[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues2[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values2[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues2[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values2[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues2[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values2[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg2[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values2[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg2[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values2[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg2[2]}
    
    ${len}=  Get Length  ${ValueSet2}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value2}=   Set Variable   ${ValueSet2[${i}]['value']}
    

    ${resp}=  Add Label for Waitlist   ${wid5}  ${labelname2[0]}  ${label_value2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label2}=    Create Dictionary   ${labelname1[0]}=${label_value1}   ${labelname2[0]}=${label_value2}   

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    Verify Response  ${resp}  ynwUuid=${wid5}  waitlistStatus=${wl_status[1]}
    Dictionary Should Contain Key   ${resp.json()['label']}  ${labelname1[0]}  
    Dictionary Should Contain Value   ${resp.json()['label']}   ${label_value1}
    Dictionary Should Contain Key   ${resp.json()['label']}  ${labelname2[0]}
    Dictionary Should Contain Value   ${resp.json()['label']}   ${label_value2}
    Should Be Equal As Strings  ${resp.json()['label']['${labelname1[0]}']}   ${label_value1}
    Should Be Equal As Strings  ${resp.json()['label']['${labelname2[0]}']}   ${label_value2}


JD-TC-AddWaitlistLabel-UH1
    [Documentation]  add label without creating label
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_waitlist  ${billable_providers[7]}
    clear_location  ${billable_providers[7]}
    clear_customer   ${billable_providers[7]}
    clear_service   ${billable_providers[7]}
    clear_queue   ${billable_providers[7]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}   
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  3  00   
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid6}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid6} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    
    
    clear_Label  ${billable_providers[7]}
    
    ${labelname6}=   FakerLibrary.word
    ${label_value6}=   FakerLibrary.word
    ${resp}=  Add Label for Waitlist   ${wid6}  ${labelname6[0]}  ${label_value6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"



JD-TC-AddWaitlistLabel-UH2
    [Documentation]  add label with non existant label name
  
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Label  ${billable_providers[7]}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${lblname7}=   FakerLibrary.word
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value7}=   Set Variable   ${ValueSet[${i}]['value']}
    ${resp}=  Add Label for Waitlist   ${wid6}  ${lblname7}  ${label_value7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"


JD-TC-AddWaitlistLabel-UH3
    [Documentation]  add label with non existant label value
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Label  ${billable_providers[7]}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    Set Suite Variable  ${lbl_name10}   ${labelname[0]}
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value10}=   Set Variable   ${ValueSet[${i}]['value']}  
    Set Suite Variable  ${label_id10}   ${label_value10}

    ${lblvalue8}=   FakerLibrary.word
    ${resp}=  Add Label for Waitlist   ${wid6}  ${labelname[0]}  ${lblvalue8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_VALUE_NOT_EXIST}"



JD-TC-AddWaitlistLabel-UH4
    [Documentation]  add label with another providers label name and value
    ...              add label to another provider's waitlist id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME227}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Label  ${PUSERNAME227}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    

    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value9}=   Set Variable   ${ValueSet[${i}]['value']}

    Set Suite Variable  ${lbl_name9}   ${labelname[0]}  
    Set Suite Variable  ${label_id9}   ${label_value9}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Add Label for Waitlist   ${wid6}  ${labelname[0]}  ${label_value9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"


JD-TC-AddWaitlistLabel-UH5
    [Documentation]  add label without sign in
    

    ${resp}=  Add Label for Waitlist   ${wid6}  ${lbl_name9}  ${label_id9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


JD-TC-AddWaitlistLabel-UH6
    [Documentation]  add label by consumer login
  
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Add Label for Waitlist   ${wid6}  ${lbl_name9}  ${label_id9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
    

JD-TC-AddWaitlistLabel-UH7
    [Documentation]  add label with empty label name

    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Log  ${lbl_name10} 
    Log  ${label_id10}
    
    ${resp}=  Add Label for Waitlist   ${wid6}  ${EMPTY}  ${label_id10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"



JD-TC-AddWaitlistLabel-UH8
    [Documentation]  add label with empty label value
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Log  ${lbl_name10} 
    Log  ${label_id10}

    ${resp}=  Add Label for Waitlist   ${wid6}   ${lbl_name10}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_VALUE_NOT_EXIST}"


JD-TC-AddWaitlistLabel-UH9
    [Documentation]  add label with non existant Waitlist id
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Log  ${lbl_name10} 
    Log  ${label_id10}

    ${resp}=  Add Label for Waitlist   000000abcdefg   ${lbl_name10}  ${label_id10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_WAITLIST}"
    

JD-TC-AddWaitlistLabel-UH10
    [Documentation]  give label name as integer

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[7]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    clear_waitlist  ${billable_providers[7]}
    clear_location  ${billable_providers[7]}
    clear_customer   ${billable_providers[7]}
    clear_service   ${billable_providers[7]}
    clear_queue   ${billable_providers[7]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}   
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_timezone_time  ${tz}  1  00  
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}  3  00   
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid2}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


    
    clear_Label  ${billable_providers[7]}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
  
    ${labelname}=    Evaluate    random.sample(range(1, 10), 2)    random
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}Star  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_START_WITH_NUMBERS}"
   