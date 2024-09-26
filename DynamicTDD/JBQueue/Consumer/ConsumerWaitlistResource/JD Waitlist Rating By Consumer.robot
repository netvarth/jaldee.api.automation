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
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}   Bleach
${SERVICE3}   Makeup
${SERVICE4}   FacialBody6
${SERVICE2}   MakeupHair6
${self}       0

*** Test Cases ***
JD-TC-Waitlist Rating By Consumer-1

	[Documentation]    Rating Added By Consumer by login of a consumer
	
    clear_queue    ${HLPUSERNAME8}
    clear_service  ${HLPUSERNAME8}
    clear_rating    ${HLPUSERNAME8}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid}=  get_acc_id  ${HLPUSERNAME8}
    Set Suite Variable  ${pid} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']} 

    ${DAY}=  db.get_date_by_timezone  ${tz}  
    Set Suite Variable  ${DAY} 
    ${desc}=  FakerLibrary.word
    ${ser_durtn}=   Random Int  min=2   max=10
    ${total_amount}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[0]}  ${total_amount}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}  ${bool[0]}  ${total_amount}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}  ${bool[0]}  ${total_amount}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_3}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${ser_durtn}  ${bool[0]}  ${total_amount}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_4}  ${resp.json()}

    ${qname}=   FakerLibrary.word
    ${sTime1}=  db.subtract_timezone_time  ${tz}   1  00
    ${eTime1}=   add_timezone_time  ${tz}    5   00
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${qname}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}   ${parallel}    ${capacity}    ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
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

    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  ${cnote}   ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${rating1}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Rating  ${pid}  ${wid}   ${rating1}   ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating1}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment}
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${rating2}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Rating  ${pid}  ${wid}  ${rating2}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating2}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment}    
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q1_l1}  ${DAY}  ${sId_3}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${rating3}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Rating  ${pid}  ${wid}  ${rating3}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating3}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment}   
    ${rating}=   Evaluate   ${rating1}.0 + ${rating2}.0 + ${rating3}.0
    ${avg_rating}=   Evaluate   ${rating}/3.0
    ${avg_round}=     roundoff    ${avg_rating}   2
    Set Suite Variable   ${avg_round}   

JD-TC-Rating Added By Consumer-UH1
	[Documentation]   Rating Added By Consumer without login  

	${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Rating  ${pid}  ${wid}  ${rating}   ${comment}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
       
JD-TC-Rating Added By Consumer-UH2
	[Documentation]   Rating Added By Consumer by another provider's account id
	
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME13}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q1_l1}  ${DAY}  ${sId_4}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${pid}=  get_acc_id  ${PUSERNAME2}

    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word

    ${resp}=  Add Rating  ${pid}  ${wid}  ${rating}  ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"

# JD-TC-Rating Added By Consumer-UH3

# 	[Documentation]   Rating Added By Consumer by another provider's account id
	
#     ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200 

#     ${pid}=  get_acc_id  ${HLPUSERNAME8}
#     ${rating}=  Random Int  min=1   max=5
#     ${comment}=   FakerLibrary.word     

#     ${resp}=  Add Rating  ${pid}  ${wid}  ${rating}  ${comment}
#     Should Be Equal As Strings  ${resp.status_code}  401  
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

    # sleep  2s      
JD-TC-Verify Waitlist Rating By Consumer-1
	[Documentation]    Verify Rating Added By Consumer by login of a consumer

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['avgRating']}  ${avg_round}   