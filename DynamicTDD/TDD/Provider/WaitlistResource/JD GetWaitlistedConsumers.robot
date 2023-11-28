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
${self}    0


*** Test Cases ***
JD-TC-Get Waitlist Consumer-1
    [Documentation]  Add To Waitlist-1

    clear_queue      ${PUSERNAME4}
    clear_location   ${PUSERNAME4}
    clear_service    ${PUSERNAME4}
    # clear waitlist   ${PUSERNAME4}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
***comment***
    ${pid}=  get_acc_id  ${PUSERNAME4}
    Set Suite Variable  ${pid}
    
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp} 

    ${CUR_DAY}=   db.get_date_by_timezone  ${tz}  
    ${DAY1}=  db.add_timezone_date  ${tz}  1 
    ${DAY2}=  db.add_timezone_date  ${tz}  2
    Set Suite Variable  ${CUR_DAY}
    Set Suite Variable  ${DAY1}
    Set Suite Variable  ${DAY2}
     
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  5  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${f_name1}=   FakerLibrary.first_name
    Set Suite Variable   ${f_name1}
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phoneno}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phoneno}  
    set Suite Variable    ${email}   ${P_Email}${phoneno}.${test_mail}
    ${resp}=  AddCustomer with email  ${f_name1}  ${l_name}  ${EMPTY}  ${email}   ${gender[1]}  ${dob}  ${phoneno}  ${EMPTY} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c1}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}   ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c2}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone1}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone1}
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${gender[1]}  ${dob}  ${phone1}  ${EMPTY}  
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
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}   ${gender[1]}  ${dob}  ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c6}  ${resp.json()}
    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}   ${gender[1]}  ${dob}  ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c7}  ${resp.json()}
    Log   ${resp.json()} 
    ${note}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${c1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${note}  ${bool[0]}  ${c1}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist  ${c2}  ${ser_id1}  ${que_id1}  ${DAY1}     ${note}  ${bool[0]}  ${c2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c3}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${note}  ${bool[0]}  ${c3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c4}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${note}  ${bool[0]}  ${c4} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist  ${c5}  ${ser_id1}  ${que_id1}  ${DAY1}     ${note}  ${bool[0]}  ${c5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c6}  ${ser_id1}  ${que_id1}  ${DAY1}     ${note}  ${bool[0]}  ${c6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${c7}  ${ser_id1}  ${que_id1}  ${DAY2}     ${note}  ${bool[0]}  ${c7} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Waitlist Consumer-2
	[Documentation]  Filter waitlisted customer by date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers  firstName-eq=${f_name1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c1}
    Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${c5}

JD-TC-Get Waitlist Consumer-3
	[Documentation]  Filter waitlisted customer by date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  3    
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c2}
    Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${c5}
    Should Be Equal As Strings  ${resp.json()[2]['consumer']['id']}  ${c6}  

JD-TC-Get Waitlist Consumer-4
	[Documentation]  Filter waitlisted customer consumre by Phone number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers  primaryMobileNo-eq=${phone1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c3}    

JD-TC-Get Waitlist Consumer-5
	[Documentation]  Filter waitlisted customer by email id
   ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers  email-eq=${email}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c1}
   
JD-TC-Get Waitlist Consumer-6
	[Documentation]  Filter waitlisted customered by day and phone number

   ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers  date-eq=${CUR_DAY}   primaryMobileNo-eq=${phone1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c3}    
    
JD-TC-Get Waitlist Consumer-7
	[Documentation]  Filter waitlisted customered by day and email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers  date-eq=${CUR_DAY}  email-eq=${email}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c1}        
    
JD-TC-Get Waitlist Consumer-8
	[Documentation]  Filter waitlisted customered by name and date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers   date-eq=${DAY1}   firstName-eq=${f_name1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c5}  

JD-TC-Get Waitlist Consumer-9
	[Documentation]  Filter waitlisted customered by name and phone number

   ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers   firstName-eq=${f_name1}   primaryMobileNo-eq=${phone2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c5}     
    
JD-TC-Get Waitlist Consumer-10
	[Documentation]  Filter waitlisted customered by name and email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}    
    ${resp}=  Get Waitlisted Consumers   firstName-eq=${f_name1}  email-eq=${email}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c1}  

JD-TC-Get Waitlist Consumer-11
	[Documentation]  Filter waitlisted customered customer by name, email,phone

   ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers   firstName-eq=${f_name2}  primaryMobileNo-eq=${phone3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c4}  

JD-TC-Get Waitlist Consumer-12
	[Documentation]  Filter waitlisted customer by name, email,phone, date

   ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers   firstName-eq=${f_name1}  email-eq=${email}   primaryMobileNo-eq=${phoneno}  date-eq=${CUR_DAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${c1} 

JD-TC-Get Waitlist Consumer-13
	[Documentation]  Filter waitlisted customered costomer by without input

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlisted Consumers   
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  7

JD-TC-Get Waitlist Consumer-UH1
	[Documentation]  with out login 

    ${resp}=  Get Waitlisted Consumers 
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   

JD-TC-Get Waitlist Consumer-UH2
    [Documentation]   with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Waitlisted Consumers   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"  
