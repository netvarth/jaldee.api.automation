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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}   Bleach1
${SERVICE3}   Makeup1
${SERVICE4}   FacialBody7
${SERVICE2}   MakeupHair7
${self}       0

*** Test Cases ***
JD-TC-Update Rating Consumer-1    
	[Documentation]    Rating Added By Consumer by login of a consumer
	
    clear_queue    ${PUSERNAME6}
    clear_service  ${PUSERNAME6}
    clear_rating    ${PUSERNAME6}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME6}
    Set Suite Variable  ${pid} 
    ${DAY}=  db.get_date_by_timezone  ${tz}  
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${desc}=  FakerLibrary.word
    ${ser_durtn}=   Random Int  min=2   max=10
    ${total_amount}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${ser_durtn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifyType[1]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_4}  ${resp.json()}
    ${qname}=   FakerLibrary.word
    ${sTime1}=  subtract_timezone_time  ${tz}   1  00
    ${eTime1}=   add_timezone_time  ${tz}    5   00
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${qname}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}   ${parallel}   ${capacity}   ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME0}
    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  ${cnote}   ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${rating1}=  Random Int  min=1   max=5
    ${comment1}=   FakerLibrary.word
    ${resp}=  Add Rating  ${pid}  ${wid}   ${rating1}   ${comment1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating1}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment1}
    ${rating2}=  Random Int  min=1   max=5
    ${comment2}=   FakerLibrary.word
    ${resp}=  Update Rating Waitlist  ${pid}  ${wid}  ${rating2}  ${comment2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating2}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment1}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][1]['comments']}  ${comment2}    

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${rating3}=  Random Int  min=1   max=5
    ${comment3}=   FakerLibrary.word
    ${resp}=  Add Rating  ${pid}  ${wid}  ${rating3}  ${comment3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating3}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment3}
    ${rating4}=  Random Int  min=1   max=5
    ${comment4}=   FakerLibrary.word
    ${resp}=  Update Rating Waitlist  ${pid}  ${wid}  ${rating4}  ${comment4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating4}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment3}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][1]['comments']}  ${comment4}
    ${rating}=   Evaluate   ${rating2}.0 + ${rating4}.0 
    ${avg_rating}=   Evaluate   ${rating}/2.0
    ${avg_round}=     roundval    ${avg_rating}   2
    Set Suite Variable   ${avg_round}   

JD-TC-Update Rating Consumer -UH1
    [Documentation]  without login and try for rating
    
    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=   Update Rating  ${wid}   ${rating}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Update Rating Consumer -UH2
    [Documentation]  comsumer try for rating providers url
    
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=   Update Rating  ${wid}   ${rating}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"      

    # sleep  2s
JD-TC-Verify Update Rating Consumer-1    
	[Documentation]    Verify Rating Added By Consumer by login of a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment  value is corretly updating in db
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['avgRating']}  ${avg_round}    
