*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}   FacialBodyABCD
${SERVICE2}   MakeupHairEFGHI
${SERVICE3}   Makeup
${SERVICE4}   Bleach
${self}       0

*** Test Cases ***
JD-TC-Reveal Phone Number of Consumer-1
	[Documentation]   Set Reveal phone number of consumer as true 
	
    clear_queue    ${PUSERNAME13}
    clear_service  ${PUSERNAME13}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME13}
    Set Suite Variable  ${pid} 
    
    ${resp}=  Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${DAY}=  db.get_date_by_timezone  ${tz}  
    Set Suite Variable  ${DAY} 
    ${desc}=  FakerLibrary.word
    ${ser_durtn}=   Random Int  min=2   max=10
    ${total_amount}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${qname}=   FakerLibrary.word
    ${sTime1}=  db.subtract_timezone_time  ${tz}   1  00
    ${eTime1}=   add_timezone_time  ${tz}    5   00
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${qname}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}   ${parallel}    ${capacity}   ${lid1}  ${sId_1}  
    Set Suite Variable  ${q1_l1}  ${resp.json()}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME13}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME13}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME13}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME13}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Add Favourite Provider  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   3s
    
    ${resp}=  List Favourite Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${pid} 
    ${cid}=  get_id  ${CUSERNAME13}
    ${cnote}=  FakerLibrary.word
    
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}   ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Reveal Phone Number  ${pid}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout 
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME13}
   
	${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME13}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 
    
    ${phne}=  Convert To String   ${CUSERNAME13}
    ${ph}=   Get Substring	 ${phne}   6   10 
    ${phone}=   Set Variable   ******${ph} 
    
    ${resp}=  Reveal Phone Number  ${pid}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}   ${phone}

          
JD-TC-Reveal Phone Number of Consumer-UH1 
	[Documentation]  Set Reveal phone number of consumer by login of a provider   
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid3}=  get_acc_id  ${PUSERNAME13}
    Set Test Variable  ${pid3} 
    ${resp}=  Reveal Phone Number  ${pid3}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ACCESS_TO_URL}"  
    
JD-TC-Reveal Phone Number of Consumer-UH2
	[Documentation]  Set Reveal phone number of consumer without login      
    
    ${resp}=  Reveal Phone Number  ${pid}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
    