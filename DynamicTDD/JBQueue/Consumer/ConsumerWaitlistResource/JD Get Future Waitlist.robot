*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        future Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py   

*** Variables ***
${self}         0
${service_duration}   5  

*** Test Cases ***

JD-TC-Get Future Waitlist Consumer-1
	[Documentation]  Add To Waitlist By Consumer valid  provider
    [setup]  Run Keywords  clear_service  ${PUSERNAME204}  AND  clear_queue  ${PUSERNAME204}  AND   clear_location  ${PUSERNAME204}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD}  
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
    ${TOMORROW}=  db.add_timezone_date  ${tz}  5    
    Set Suite Variable  ${TOMORROW} 
    ${TestDate}=  db.add_timezone_date  ${tz}  6  
    Set Suite Variable  ${TestDate}
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.firstname
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
    ${p1queue2}=    FakerLibrary.firstname
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q2}  ${resp.json()}

    ${sTime3}=  add_timezone_time  ${tz}  1  30  
    ${eTime3}=  add_timezone_time  ${tz}  2  00  
    ${p1queue3}=    FakerLibrary.lastname
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q3}  ${resp.json()}

    ${resp}=    Update Waitlist Settings  ${calc_mode[1]}  30  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=30  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}   maxPartySize=1
    
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cid}  ${resp.json()['id']}  
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q2}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${f1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q3}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TestDate}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${uuid1}  ${waitlist_cancl_reasn[4]}  ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Get Future Waitlist Consumer-2

	[Documentation]   Get Filter Future waitlist by service id
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist  service-eq=${p1_s2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4    
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${p1_s2}   
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${p1_s2}    
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()[3]['service']['id']}  ${p1_s2}

JD-TC-Get Future Waitlist Consumer-3
	[Documentation]  Get Future Waitlist By queue id
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist  queue-eq=${p1_q2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q2} 

JD-TC-Get Future Waitlist Consumer-4
	[Documentation]  Get Future Waitlist By first name of family member
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist  waitlistingFor-eq=firstName::${firstName}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${count}=  Get Length  ${resp.json()} 
    Log  ${count}
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TOMORROW} 

JD-TC-Get Future Waitlist Consumer-5
	[Documentation]  Get Future Waitlist By last name of family member
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist  waitlistingFor-eq=lastName::${lastName}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${count}=  Get Length  ${resp.json()} 
    Log  ${count}
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TOMORROW} 

# JD-TC-Get Future Waitlist Consumer-6
# 	[Documentation]  Get Future Waitlist By jaldeeid of family member
#     ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Future Waitlist  waitlistingFor-eq=jaldeeId::${f1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${count}=  Get Length  ${resp.json()} 
#     Log  ${count}
#     Should Be Equal As Integers  ${count}  1
#     Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TOMORROW} 

JD-TC-Get Future Waitlist Consumer-7
	[Documentation]  Get Future Waitlist By waitlist status
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    
JD-TC-Get Future Waitlist Consumer-8
	[Documentation]  Get Future Waitlist By waitlist status
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist  date-eq=${TestDate}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TestDate}     

JD-TC-Get Future Waitlist Consumer-9
	[Documentation]  Get Future Waitlist By queue id and status
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q1} 
    
JD-TC-Get Future Waitlist Consumer-10
	[Documentation]  Get Future Waitlist By token
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Future Waitlist   token-eq=${token}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TOMORROW} 

JD-TC-Get Future Waitlist Consumer-11
	[Documentation]  Get Future Waitlist By service-eq=${p1_s2}  waitlistStatus-eq=${wl_status[0]}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   service-eq=${p1_s1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[0]}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${p1_s1}   

JD-TC-Get Future Waitlist Consumer-12
	[Documentation]  Get Future Waitlist By  queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[0]}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  3
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}  ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${p1_q1}   
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}  ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()[2]['queue']['id']}  ${p1_q1} 

JD-TC-Get Future Waitlist Consumer-13
    [Documentation]  Get Future Waitlist By service-eq=${p1_s2}  waitlistStatus-eq=${wl_status[4]}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Cancel Waitlist  ${uuid2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Future Waitlist   service-eq=${p1_s2}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${p1_s2} 

JD-TC-Get Future Waitlist Consumer-14
	[Documentation]  Get Future Waitlist By queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q1}   
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${p1_q1}   


JD-TC-Get Future Waitlist Consumer-15
	[Documentation]  Get Future Waitlist By queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q1}   
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${p1_q1}   

JD-TC-Get Future Waitlist Consumer-16
	[Documentation]  Get Future Waitlist By queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   queue-eq=${p1_q1}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q1}   
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${p1_q1}     

JD-TC-Get Future Waitlist Consumer-17
	[Documentation]  Get Future Waitlist By queue-eq=${p1_q1}  date-eq=${TestDate}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   queue-eq=${p1_q1}  date-eq=${TestDate}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TestDate}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${p1_q1}    

JD-TC-Get Future Waitlist Consumer-18
	[Documentation]  Get Future Waitlist By  service-eq=${p1_s2}  date-eq=${TOMORROW}
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Future Waitlist   service-eq=${p1_s2}  date-eq=${TOMORROW}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  3
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${TOMORROW}

JD-TC-Get Future Waitlist Consumer-UH1
	[Documentation]  with out login 

    ${resp}=  Get Future Waitlist   waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   

JD-TC-FamilyMember-CLEAR
    clear_Family  ${f1}    