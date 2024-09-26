*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags      future Waitlist
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py 

*** Variables ***
${self}         0
${service_duration}   5  

*** Test Cases ***

JD-TC-Get Future Waitlist Count-1
	
    [Documentation]  Add To Waitlist By Consumer valid  provider
    
    [Setup]  Run Keywords  clear_queue  ${PUSERNAME205}  AND  clear_location  ${PUSERNAME205}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${TOMORROW}=  db.add_timezone_date  ${tz}  2   
    Set Suite Variable  ${TOMORROW}
    ${TOMORROW1}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable  ${TOMORROW1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}   
       
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue2}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q2}  ${resp.json()}

    ${resp}=    Update Waitlist Settings  ${calc_mode[1]}  30  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  1s

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=30  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}    maxPartySize=1
 
    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME7}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME7}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # clear_Consumermsg  ${CUSERNAME14}
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable  ${cid}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q2}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid3}  ${wid[0]}

    ${firstname}=  FakerLibrary.firstname
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${f1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${f1} 
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q2}  ${TOMORROW1}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
        
JD-TC-Get Future Waitlist Count-2
	
    [Documentation]  Filter waitlist by service id
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count  service-eq=${p1_s2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   3
  
   
JD-TC-Get Future Waitlist Count-3
	
    [Documentation]  Filter waitlist by queue id
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count  queue-eq=${p1_q2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Get Future Waitlist Count-4
	
    [Documentation]  Filter waitlist by first name of family member
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count  waitlistingFor-eq=firstName::${firstName}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Future Waitlist Count-5
	
    [Documentation]  Filter waitlist by waitlist status
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  5
        
JD-TC-Get Future Waitlist Count-6
	
    [Documentation]  Filter waitlist by queue id and service id
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count  service-eq=${p1_s1}  queue-eq=${p1_q1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get Future Waitlist Count-7
	
    [Documentation]  Filter waitlist by queue id and status
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3
    
JD-TC-Get Future Waitlist Count-8
	
    [Documentation]  Filter waitlist by service-eq=${p1_s1}  waitlistStatus-eq=${wl_status[0]}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   service-eq=${p1_s1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
JD-TC-Get Future Waitlist Count-9
	
    [Documentation]  Filter waitlist by token
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Future Waitlist Count   token-eq=${token}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Future Waitlist Count-10
	
    [Documentation]  Filter waitlist by service-eq=${p1_s1}  waitlistStatus-eq=${wl_status[0]}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   service-eq=${p1_s1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Get Future Waitlist Count-11
	
    [Documentation]  Filter waitlist by  queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[0]}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-Get Future Waitlist Count-12
	
    [Documentation]  Filter waitlist by queue-eq=${p1_q1}  date-eq=${TOMORROW}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   queue-eq=${p1_q1}  date-eq=${TOMORROW}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-Get Future Waitlist Count-13
    
    [Documentation]  Filter waitlist by service-eq=${p1_s1}  date-eq=${TOMORROW}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   service-eq=${p1_s1}  date-eq=${TOMORROW}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Get Future Waitlist Count-14
    
    [Documentation]  Filter waitlist by date-eq=${TOMORROW1}  
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count   date-eq=${TOMORROW1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get Future Waitlist Count-15
	
    [Documentation]  Get Future Waitlist By queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Future Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Future Waitlist Count   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0

JD-TC-Get Future Waitlist Count-16
	
    [Documentation]  Filter waitlist by last name of family member
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME7}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist Count  waitlistingFor-eq=lastName::${lastName}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get Future Waitlist Count-UH1
	
    [Documentation]  with out login 
    
    ${resp}=  Get Future Waitlist Count   waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   
