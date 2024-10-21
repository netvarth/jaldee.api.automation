*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2
${SERVICE3}    SERVICE3
${self}       0
@{service_names}

*** Test Cases ***

JD-TC-Get Waitlist history count-1

    [Documentation]  Add To Waitlists
    
    change_system_date  -5

    # clear_queue      ${HLPUSERNAME12}
    # clear_location   ${HLPUSERNAME12}
    # clear_service    ${HLPUSERNAME12}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${HLPUSERNAME12}
    Set Suite Variable  ${pid} 
    
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}

    ${DAY}=  db.get_date_by_timezone  ${tz}  
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY}
    Set Suite Variable  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']

    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    ${sTime1}=  add_timezone_time  ${tz}  1  00  
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}  
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${sId_1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${sId_1}
    ${sId_2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${sId_2}
    ${sId_3}=   Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${sId_3} 

    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       0  20 
    Set Suite Variable    ${end_time} 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}   ${capacity}    ${lid}  ${sId_3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qId1}   ${resp.json()}

    ${q_name1}=    FakerLibrary.name
    Set Suite Variable    ${q_name1}
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue  ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qId2}  ${resp.json()}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME18}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    # ${resp}=  Provider Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${qId2}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid0}  ${wid[0]}

    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${qId1}  ${DAY}  ${sId_3}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}    

    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${qId2}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${qId2}  ${DAY1}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}    

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${token}  ${resp.json()['token']} 

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid0}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid0} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reasn}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel   ${wid1}   ${waitlist_cancl_reasn[4]}   ${reasn}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    sleep  2s

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-Get Waitlist history Count-2

    [Documentation]  Get Waitlist history By queue
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200   

    ${resp}=  Get Waitlist History Count Consumer  queue-eq=${qId1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

    ${resp}=  Get Waitlist History Count Consumer  queue-eq=${qId2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Waitlist history Count-3

    [Documentation]   Get Waitlist history location
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist History Count Consumer  location-eq=${lid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  3

    ${resp}=  Get Waitlist History Count Consumer  location-eq=${lid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Waitlist history Count-4

    [Documentation]   Get Waitlist history service
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer  service-eq=${sId_1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  2
            
JD-TC-Get Waitlist history Count-5

    [Documentation]   Get Waitlist history first name  
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}    

    ${resp}=  Get Waitlist History Count Consumer  firstName-eq=${cname1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  4

JD-TC-Get Waitlist history Count-6

    [Documentation]   Get Waitlist history Date
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200  

    ${resp}=  Get Waitlist History Count Consumer  date-eq=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  1

    ${resp}=  Get Waitlist History Count Consumer  date-eq=${DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  3


JD-TC-Get Waitlist history Count-7

    [Documentation]   Get Waitlist history waitlist status checkin
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200  

    ${resp}=  Get Waitlist History Count Consumer  waitlistStatus-eq=${wl_status[0]}  
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Waitlist history Count-8

    [Documentation]   Get Waitlist history waitlist status arrived
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer  waitlistStatus-eq=${wl_status[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Integers  ${resp.json()}  1  

JD-TC-Get Waitlist history Count-9

    [Documentation]   Get Waitlist history waitlist status canceled
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer  waitlistStatus-eq=${wl_status[4]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  1    

JD-TC-Get Waitlist history Count-10

    [Documentation]   Get Waitlist history  location-eq=${lid1}  queue-eq=${qId1}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer  location-eq=${lid}  queue-eq=${qId1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  1    
   
JD-TC-Get Waitlist history Count-11

    [Documentation]   Get Waitlist history  location-eq=${lid1}  service-eq=${sId_1}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer  queue-eq=${qId2}  service-eq=${sId_1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  2    

JD-TC-Get Waitlist history Count-12

    [Documentation]   Get Waitlist history  location-eq=${lid1}  service-eq=${sId_1}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer  location-eq=${lid1}  service-eq=${sId_1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  2   

JD-TC-Get Waitlist history Count-13

    [Documentation]   Get Waitlist history  no input
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Get Waitlist History Count Consumer   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  4             
    
JD-TC-Get Waitlist history Count-UH1

    [Documentation]   Get Waitlist history  without login
    
    ${resp}=  Get Waitlist History Count Consumer
    Log  ${resp.json()}        
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}               
     

