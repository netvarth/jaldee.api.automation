*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
@{rating}                Exellent   Very Good    Good    Fair    Poor
@{rating_stars}          5    4    3     2     1

*** Test Cases ***
JD-TC-Update Waitist rating-1
    [Documentation]   a provider Waitlisted consumer gives Rating 

    clear_Rating     ${PUSERNAME15}
    clear_queue      ${PUSERNAME15}
    clear_location   ${PUSERNAME15}
    clear_service    ${PUSERNAME15}
    clear_customer    ${PUSERNAME15}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Test Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Test Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}      
    ${q_name}=    FakerLibrary.name
    Set Test Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}  
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity} 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}   ${loc_id1}  ${ser_id1}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable    ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}    
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[0]}   ${rating[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[0]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[0]} 
    ${resp}=   Update Rating  ${uuid}   ${rating_stars[4]}   ${rating[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[4]} 
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[0]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][1]['comments']}   ${rating[4]}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}     
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Waitlist Rating  ${uuid}   ${rating_stars[4]}   ${rating[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[4]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[4]}    
    ${resp}=   Update Rating  ${uuid}   ${rating_stars[0]}   ${rating[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[0]}                
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[4]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][1]['comments']}   ${rating[0]}   
    ${avg_rating1}=   Evaluate    ${rating_stars[4]}.0+${rating_stars[0]}.0
    ${avg_rating}=    Evaluate    ${avg_rating1}/2.0  
    sleep  02s
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    comment   value is correctly updating in db

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['avgRating']}   ${avg_rating}  
   
    
JD-TC-Update Waitlist Rating -UH1
    [Documentation]  without login and try for rating

    ${resp}=   Update Rating  ${uuid}   ${rating_stars[2]}   ${rating[2]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Update Waitlist Rating _UH2
    [Documentation]  comsumer try for rating providers url

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Update Rating  ${uuid}   ${rating_stars[3]}   ${rating[3]}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"   
    
       
    
        
    
