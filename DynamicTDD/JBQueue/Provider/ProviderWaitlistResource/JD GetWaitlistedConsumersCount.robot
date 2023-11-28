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
@{gender}                 Female    Male

*** Test Cases ***
JD-TC-Get Waitlist Consumer count-1
    [Documentation]  Add To Waitlist-1

    clear_queue      ${PUSERNAME5}
    clear_location   ${PUSERNAME5}
    clear_service    ${PUSERNAME5}
    # clear waitlist   ${PUSERNAME5}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
***comment***
    ${pid}=  get_acc_id  ${PUSERNAME5}
    Set Suite Variable  ${pid}  ${pid}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY}=  db.add_timezone_date  ${tz}  0  
    ${DAY1}=  db.add_timezone_date  ${tz}  1 
    ${DAY2}=  db.add_timezone_date  ${tz}  2
    Set Suite Variable  ${DAY}
    Set Suite Variable  ${DAY1}
    Set Suite Variable  ${DAY2}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  5  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=12   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${f_name1}=   FakerLibrary.first_name
    Set Suite Variable   ${f_name1}
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phoneno}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phoneno}
    ${email}=    FakerLibrary.email
    set Suite Variable    ${email}
    ${resp}=  AddCustomer with email  ${f_name1}  ${l_name}  ${EMPTY}  ${email}   ${gender[1]}  ${dob}  ${phoneno}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c1}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}  ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c2}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone1}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone1}
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}   ${phone1}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c3}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name2}=   FakerLibrary.first_name
    Set Suite Variable   ${f_name2}
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone3}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone3}
    ${resp}=  AddCustomer without email  ${f_name2}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}  ${phone3}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c4}  ${resp.json()}
    Log   ${resp.json()}
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone2}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone2}
    ${resp}=  AddCustomer without email  ${f_name1}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}  ${phone2}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c5}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}  ${phone}  ${EMPTY}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c6}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}   ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c7}  ${resp.json()}
    Log   ${resp.json()} 
    ${note}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${c1}  ${ser_id1}  ${que_id1}  ${DAY}   ${note}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist  ${c2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${note}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c3}  ${ser_id1}  ${que_id1}  ${DAY}   ${note}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c4}  ${ser_id1}  ${que_id1}  ${DAY}   ${note}  ${bool[0]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist  ${c5}  ${ser_id1}  ${que_id1}  ${DAY1}  ${note}  ${bool[0]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c6}  ${ser_id1}  ${que_id1}  ${DAY1}  ${note}  ${bool[0]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c7}  ${ser_id1}  ${que_id1}  ${DAY2}  ${note}  ${bool[0]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Waitlist Consumer count-2
    [Documentation]  count waitlisted consumer by first name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count  firstName-eq=${f_name1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
JD-TC-Get Waitlist Consumer count-3
    [Documentation]  count waitlisted consumer by date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3    
    

JD-TC-Get Waitlist Consumer count-4
    [Documentation]  count waitlisted consumer consumre by Phone number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count  primaryMobileNo-eq=${phone2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Waitlist Consumer count-5
    [Documentation]  count waitlisted consumer by email id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count  email-eq=${email}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
   
JD-TC-Get Waitlist Consumer count-6
    [Documentation]  count waitlisted consumer by  day and phone number 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count  date-eq=${DAY}   primaryMobileNo-eq=${phone3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get Waitlist Consumer count-7
    [Documentation]  count waitlisted by day and email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count  date-eq=${DAY}  email-eq=${email}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get Waitlist Consumer count-8
    [Documentation]  count waitlisted consumer  by name  and date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count   date-eq=${DAY1}   firstName-eq=${f_name1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Waitlist Consumer count-9
    [Documentation]  count waitlisted consumer  by name and phone number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count   firstName-eq=${f_name1}  primaryMobileNo-eq=${phone2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get Waitlist Consumer count-10
    [Documentation]  count waitlisted consumer by name and email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}    
    ${resp}=  Get Waitlisted Consumers Count   firstName-eq=${f_name1}  email-eq=${email}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Waitlist Consumer count-11
    [Documentation]  count waitlisted customer by name, email,phone

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count   firstName-eq=${f_name1}  email-eq=${email}   primaryMobileNo-eq=${phoneno}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Waitlist Consumer count-12
    [Documentation]  count waitlisted consumer by  name, email,phone, date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count   firstName-eq=${f_name1}  email-eq=${email}   primaryMobileNo-eq=${phoneno}  date-eq=${DAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Waitlist Consumer count-13
    [Documentation]  count waitlisted customer by without input 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers Count   
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  7

JD-TC-Get Waitlist Consumer count-UH1
    [Documentation]  with out login 

    ${resp}=  Get Waitlisted Consumers Count   
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  
     
JD-TC-Get Waitlist Consumer count-UH2
    [Documentation]  consumer try to use cweightlisted consumer count

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Waitlisted Consumers Count   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"     
