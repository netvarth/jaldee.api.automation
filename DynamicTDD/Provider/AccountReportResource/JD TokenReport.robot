*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Token Report
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


       
*** Variables ***
${SERVICE1}     SERVICE1
${SERVICE2}     SERVICE2
${SERVICE3}     SERVICE3
${SERVICE4}     SERVICE4
${P1SERVICE1}   P1SERVICE1
${P1SERVICE2}   P1SERVICE2
${P1SERVICE3}   P1SERVICE3
${P1SERVICE4}   P1SERVICE4
${V1SERVICE1}   V1SERVICE1
${V1SERVICE2}   V1SERVICE2
${V1SERVICE3}   V1SERVICE3
${V1SERVICE4}   V1SERVICE4
${parallel}     1
${digits}       0123456789
${self}         0
@{service_duration}   5   20
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
@{Statuses}    NEW    INPROGRESS   CANCELED    FALIED    PDFUPLOADED     SEEN
@{EMPTY_List}


*** Test Cases ***

JD-TC-Token_Report-1
    [Documentation]  Generate current_day report of a provider for both online and walk-in checkin for any PHYSICAL SERVICE
    
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME20}
    Set Suite Variable  ${pid}

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    clear_queue     ${PUSERNAME20}
    clear_service   ${PUSERNAME20}
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${firstname1}=  FakerLibrary.first_name
    Set Test Variable  ${firstname1}
    set Suite Variable  ${email}  ${firstname1}${cid}${C_Email}.ynwtest@netvarth.com

    
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

   

    ${servicecharge2}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge2}
    Set Suite Variable   ${min_pre2}   ${servicecharge2}
    ${Total2}=  Convert To Number  ${servicecharge2}  1 
    Set Suite Variable   ${Total2}
    ${amt_float2}=  twodigitfloat  ${Total2}
    Set Suite Variable  ${amt_float2} 

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   20   ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}
    Set Suite Variable  ${p1queue1}
     
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${C8_name}   ${resp.json()['userName']}
    ${pcid8}=  get_id  ${CUSERNAME8}

    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    Set Suite Variable   ${C8_fname}   ${family_fname} ${family_lname}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s2}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid2}  ${wid[0]} 

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s1}  ${msg}  ${bool[0]}  ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid3}  ${wid[0]} 

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s2}  ${msg}  ${bool[0]}  ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid4}  ${wid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c8}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Get Waitlist By Id  ${cwid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_cf8}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}


    ${resp}=  Get Waitlist By Id  ${cwid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid10}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid10}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_id}  ${resp.json()[0]['jaldeeConsumer']}

    ${resp}=  Add To Waitlist  ${cid10}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cid10} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    

    ${resp}=  Add To Waitlist  ${cid10}  ${p1_s2}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cid10} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}


    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c10}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}   futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory}      TODAY

    
    # ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${token_id}   ${resp.json()}


    # sleep  3s
    # ${resp}=  Get Report Status By Token Id  ${token_id}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${Date} =	Convert Date	${DAY}	result_format=%d/%m/%Y

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c10}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}

    Should Be Equal As Strings  Token/Check-in Date   ${resp.json()['reportContent']['columns']['1']}  # Date
    Should Be Equal As Strings  Customer ID           ${resp.json()['reportContent']['columns']['2']}  # CustomerId
    Should Be Equal As Strings  Customer Name         ${resp.json()['reportContent']['columns']['3']}  # CustomerName
    Should Be Equal As Strings  Customer Phone        ${resp.json()['reportContent']['columns']['4']}  # CustomerPhone
    Should Be Equal As Strings  Queue                 ${resp.json()['reportContent']['columns']['5']}  # QueueName
    Should Be Equal As Strings  Service               ${resp.json()['reportContent']['columns']['6']}  # ServiceName
    Should Be Equal As Strings  Confirmation Number   ${resp.json()['reportContent']['columns']['7']}  # ConfirmationId
    Should Be Equal As Strings  Status                ${resp.json()['reportContent']['columns']['8']}  # Status
    Should Be Equal As Strings  Mode                  ${resp.json()['reportContent']['columns']['9']}  # Mode
    Should Be Equal As Strings  Payment Status        ${resp.json()['reportContent']['columns']['10']}  # PaymentStatus 
    Should Be Equal As Strings  Amount Paid           ${resp.json()['reportContent']['columns']['11']}  # AmountPaid


    Should Be Equal As Strings  ${Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c10}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Arrived   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id100}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    


    Should Be Equal As Strings  ${Date}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c10}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_name}           ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE2}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Arrived              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    

     
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c8},${jid_cf8}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c8}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c8},${jid_cf8}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today                ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
   
    Should Be Equal As Strings  ${Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c8}            ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${C8_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id82}      ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf8}            ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${C8_fname}           ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id83}      ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    ${resp}=  Get Report By Status       ${Statuses[0]}  ${Statuses[1]}  ${Statuses[2]}  ${Statuses[3]}  ${Statuses[4]}  ${Statuses[5]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Token_Report-2
    [Documentation]  Generate Next_Week report of a provider for both online and walk-in checkin for any PHYSICAL SERVICE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    ${Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY1}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid11}  ${wid[0]} 

    ${Add_DAY2}=  db.add_timezone_date  ${tz}  2  
    ${Date2} =	Convert Date	${Add_DAY2}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY2}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid12}  ${wid[0]}

    ${Add_DAY3}=  db.add_timezone_date  ${tz}  3  
    ${Date3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY3}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid13}  ${wid[0]}

    ${Add_DAY4}=  db.add_timezone_date  ${tz}  4  
    ${Date4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY4}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid14}  ${wid[0]}

    ${Add_DAY5}=  db.add_timezone_date  ${tz}  5  
    ${Date5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY5}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid15}  ${wid[0]}

    ${Add_DAY6}=  db.add_timezone_date  ${tz}  6  
    ${Date6} =	Convert Date	${Add_DAY6}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY6}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid16}  ${wid[0]}

    ${Add_DAY7}=  db.add_timezone_date  ${tz}  7  
    ${Date7} =	Convert Date	${Add_DAY7}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY7}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid17}  ${wid[0]}

    ${Add_DAY8}=  db.add_timezone_date  ${tz}  8  
    ${Date8} =	Convert Date	${Add_DAY8}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY8}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid18}  ${wid[0]}

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${Current_Date} =	Convert Date	${TODAY}	result_format=%d/%m/%Y
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TODAY}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid19}  ${wid[0]}

    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY1}  ${p1_s2}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid20}  ${wid[0]} 


    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid11} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c18}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Get Waitlist By Id  ${cwid12} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid13} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid14} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid15} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid16} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid17} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid18} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid19} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid20} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid20}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_id20}  ${resp.json()[0]['jaldeeConsumer']}

   
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s1}  ${p1_q1}  ${Add_DAY1}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s2}  ${p1_q1}  ${Add_DAY2}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid12}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s1}  ${p1_q1}  ${Add_DAY3}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid13}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s2}  ${p1_q1}  ${Add_DAY4}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid14}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s1}  ${p1_q1}  ${Add_DAY5}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid15}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s2}  ${p1_q1}  ${Add_DAY6}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid16}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s1}  ${p1_q1}  ${Add_DAY7}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid17}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s2}  ${p1_q1}  ${Add_DAY8}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid18}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s1}  ${p1_q1}  ${TODAY}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid19}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid20}  ${p1_s2}  ${p1_q1}  ${TODAY}  ${desc}  ${bool[1]}  ${cid20} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid20}  ${wid[0]}


    ${resp}=  Get Waitlist By Id  ${wid11} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c20}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Get Waitlist By Id  ${wid12} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c18}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain    ${resp.json()}  ${Add_DAY8}
    Should Not Contain    ${resp.json()}  ${TODAY}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c18}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c18}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  7                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid201}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date2}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid202}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid203}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid204}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid205}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date6}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid206}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c18}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid207}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c18}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c20}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${Date8}
    Should Not Contain    ${resp.json()}  ${Current_Date}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c20}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c20}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  7                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid201}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date2}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE2}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid202}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid203}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE2}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid204}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid205}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date6}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE2}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid206}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c20}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_pid207}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    

    

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c20}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id3}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 

JD-TC-Token_Report-3
    [Documentation]  Generate current_day report of a provider for both online and walk-in checkin for any VIRTUAL SERVICE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${ZOOM_id2}=  Format String  ${ZOOM_url}  ${PUSERNAME20}
    Set Suite Variable   ${ZOOM_id2}

    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERNAME20}
    Set Suite Variable   ${ZOOM_Pid2}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${description}=    FakerLibrary.word
    # ${vstype}=  Evaluate  random.choice($vservicetype)  random
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${V1SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Service_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${Service_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${V1SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}


    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${v1_s1}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_s2}   ${resp.json()[1]['id']}
   
    

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue2}=    FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   20   ${p1_l1}  ${v1_s1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q2}  ${resp.json()}
    Set Suite Variable   ${p1queue2}
    ${virtualService1}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id2}
    Set Suite Variable  ${virtualService1}
    
    ${resp}=  AddCustomer  ${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid33}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid33}  ${resp.json()[0]['id']}

    ${firstname23}=  FakerLibrary.first_name
    ${lastname23}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${note}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid33}  ${firstname23}  ${lastname23}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fid23}  ${resp.json()}
    Set Suite Variable  ${fname23}  ${firstname23} ${lastname23}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Provider Add To WL With Virtual Service  ${cid33}  ${v1_s1}  ${p1_q2}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${cid33}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid_v1}  ${wid[0]}

    
    ${resp}=  Provider Add To WL With Virtual Service  ${cid33}  ${v1_s1}  ${p1_q2}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${fid23}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid_v2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid_v1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby[1]}   personsAhead=0  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${V1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${v1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid33}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid33}

    ${resp}=  Get Waitlist By Id  ${wid_v2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby[1]}   personsAhead=1  onlineRequest=${bool[0]}   waitlistMode=${waitlistMode[2]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${V1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${v1_s1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid33}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${fid23}

    ${resp}=  Get Waitlist By Id  ${wid_v1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c23}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Get Waitlist By Id  ${wid_v2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_cf23}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}


    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname_f25}=  FakerLibrary.first_name
    ${lname_f25}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${fname_f25}  ${lname_f25}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${fid25}   ${resp.json()}
    Set Suite Variable   ${C25_fname}   ${fname_f25} ${lname_f25}

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${DAY1}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${Cwid_v1}  ${wid[0]}

    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${DAY1}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   ${fid25}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${Cwid_v2}  ${wid[0]}
    

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${Cwid_v1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c25}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Get Waitlist By Id  ${Cwid_v2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_cf25}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}


    ${resp}=  Get Waitlist By Id  ${Cwid_v2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Date1} =	Convert Date	${DAY1}	result_format=%d/%m/%Y

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory}      TODAY

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_cf23},${jid_c23}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  3s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c23}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf23},${jid_c23}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c23}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  Phone in   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
    
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf23}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${fname23}           ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In             ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  Phone in   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    # Should Be Equal As Strings  ${Checkin_mode[2]}   ${resp.json()['reportContent']['data'][1]['8']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c25}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  3s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c25}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c25}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c25}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_cf25}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
    
    sleep  3s
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c25}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf25}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf25}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${C25_fname}           ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In             ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_fid304}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
    

JD-TC-Token_Report-4
    [Documentation]  Generate Next_Week report of a provider for both online and walk-in checkin for any VIRTUAL SERVICE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid28}=  get_id  ${CUSERNAME28}

    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    ${Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY1}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v1}  ${wid[0]}
  
    ${Add_DAY2}=  db.add_timezone_date  ${tz}  2  
    ${Date2} =	Convert Date	${Add_DAY2}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY2}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v2}  ${wid[0]}

    ${Add_DAY3}=  db.add_timezone_date  ${tz}  3  
    ${Date3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY3}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v3}  ${wid[0]}
    
    ${Add_DAY4}=  db.add_timezone_date  ${tz}  4  
    ${Date4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY4}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v4}  ${wid[0]}

    ${Add_DAY5}=  db.add_timezone_date  ${tz}  5  
    ${Date5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY5}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v5}  ${wid[0]}
   
    ${Add_DAY6}=  db.add_timezone_date  ${tz}  6  
    ${Date6} =	Convert Date	${Add_DAY6}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY6}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v6}  ${wid[0]}

    ${Add_DAY7}=  db.add_timezone_date  ${tz}  7  
    ${Date7} =	Convert Date	${Add_DAY7}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY7}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v7}  ${wid[0]}
    
    ${Add_DAY8}=  db.add_timezone_date  ${tz}  8  
    ${Date8} =	Convert Date	${Add_DAY8}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY8}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v8}  ${wid[0]}

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${Current_Date} =	Convert Date	${TODAY}	result_format=%d/%m/%Y
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${TODAY}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v9}  ${wid[0]}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid_v1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c28}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c28}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${Date8}
    Should Not Contain    ${resp.json()}  ${Current_Date}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c28}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c28}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  7                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid401}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date2}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid402}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid403}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid404}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid405}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date6}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid406}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c28}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid407}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c28}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id3}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Token_Report-5
    [Documentation]  Generate NEXT_THIRTY_DAYS report of a provider for both online and walk-in checkin For any PHYSICAL SERVICE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid33}=  get_id  ${CUSERNAME33}

    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date1}
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY1}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p1}  ${wid[0]}

    ${Add_DAY4}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable  ${Add_DAY4}
    ${Date4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date4}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY4}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p4}  ${wid[0]}

    ${Add_DAY7}=  db.add_timezone_date  ${tz}  7  
    Set Suite Variable  ${Add_DAY7}
    ${Date7} =	Convert Date	${Add_DAY7}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date7}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY7}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p7}  ${wid[0]}

    ${Add_DAY10}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${Add_DAY10}
    ${Date10} =	Convert Date	${Add_DAY10}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date10}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY10}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p10}  ${wid[0]}
  
    ${Add_DAY14}=  db.add_timezone_date  ${tz}  14
    Set Suite Variable  ${Add_DAY14}
    ${Date14} =	Convert Date	${Add_DAY14}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date14}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY14}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p14}  ${wid[0]}

    ${Add_DAY19}=  db.add_timezone_date  ${tz}  19
    Set Suite Variable  ${Add_DAY19}
    ${Date19} =	Convert Date	${Add_DAY19}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date19}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY19}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p19}  ${wid[0]}
    
    ${Add_DAY23}=  db.add_timezone_date  ${tz}  23
    Set Suite Variable  ${Add_DAY23}
    ${Date23} =	Convert Date	${Add_DAY23}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date23}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY23}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p23}  ${wid[0]}

    ${Add_DAY27}=  db.add_timezone_date  ${tz}  27
    Set Suite Variable  ${Add_DAY27}
    ${Date27} =	Convert Date	${Add_DAY27}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date27}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY27}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p27}  ${wid[0]}
   
    ${Add_DAY30}=  db.add_timezone_date  ${tz}  30
    Set Suite Variable  ${Add_DAY30}
    ${Date30} =	Convert Date	${Add_DAY30}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date30}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY30}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p30}  ${wid[0]}

    ${Add_DAY31}=  db.add_timezone_date  ${tz}  31
    Set Suite Variable  ${Add_DAY31}
    ${Date31} =	Convert Date	${Add_DAY31}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date31}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY31}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p31}  ${wid[0]}
    
    ${Add_DAY36}=  db.add_timezone_date  ${tz}  36
    Set Suite Variable  ${Add_DAY36}
    ${Date36} =	Convert Date	${Add_DAY36}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date36}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY36}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p36}  ${wid[0]}

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${Current_Date} =	Convert Date	${TODAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Current_Date}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TODAY}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p0}  ${wid[0]}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid_p1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c33}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c33}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${Current_Date}
    Should Not Contain    ${resp.json()}  ${Date31}
    Should Not Contain    ${resp.json()}  ${Date36}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c33}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c33}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  9                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid501}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid504}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid507}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid510}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date14}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid514}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date19}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid519}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date23}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid523}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date27}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid527}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid530}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    


    Set Test Variable  ${reportDateCategory2}      LAST_THIRTY_DAYS
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c33}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Token_Report-6
    [Documentation]  Generate NEXT_THIRTY_DAYS report of a provider for both online and walk-in checkin For any VIRTUAL SERVICE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid30}=  get_id  ${CUSERNAME30}

    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date1}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY1}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v1}  ${wid[0]}

    ${Add_DAY5}=  db.add_timezone_date  ${tz}  5  
    Set Suite Variable  ${Add_DAY5}
    ${Date5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date5}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY5}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v5}  ${wid[0]}

    ${Add_DAY8}=  db.add_timezone_date  ${tz}  8  
    Set Suite Variable  ${Add_DAY8}
    ${Date8} =	Convert Date	${Add_DAY8}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date8}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY8}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v8}  ${wid[0]}

    ${Add_DAY10}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${Add_DAY10}
    ${Date10} =	Convert Date	${Add_DAY10}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date10}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY10}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v10}  ${wid[0]}
  
    ${Add_DAY15}=  db.add_timezone_date  ${tz}  15  
    Set Suite Variable  ${Add_DAY15}
    ${Date15} =	Convert Date	${Add_DAY15}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date15}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY15}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v15}  ${wid[0]}

    ${Add_DAY20}=  db.add_timezone_date  ${tz}  20
    Set Suite Variable  ${Add_DAY20}
    ${Date20} =	Convert Date	${Add_DAY20}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date20}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY20}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v20}  ${wid[0]}
    
    ${Add_DAY24}=  db.add_timezone_date  ${tz}  24
    Set Suite Variable  ${Add_DAY24}
    ${Date24} =	Convert Date	${Add_DAY24}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date24}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY24}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v24}  ${wid[0]}

    ${Add_DAY28}=  db.add_timezone_date  ${tz}  28
    Set Suite Variable  ${Add_DAY28}
    ${Date28} =	Convert Date	${Add_DAY28}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date28}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY28}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v28}  ${wid[0]}
   
    ${Add_DAY30}=  db.add_timezone_date  ${tz}  30
    Set Suite Variable  ${Add_DAY30}
    ${Date30} =	Convert Date	${Add_DAY30}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date30}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY30}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v30}  ${wid[0]}

    ${Add_DAY31}=  db.add_timezone_date  ${tz}  31
    Set Suite Variable  ${Add_DAY31}
    ${Date31} =	Convert Date	${Add_DAY31}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date31}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY31}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v31}  ${wid[0]}
    
    ${Add_DAY35}=  db.add_timezone_date  ${tz}  35
    Set Suite Variable  ${Add_DAY35}
    ${Date35} =	Convert Date	${Add_DAY35}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date35}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY35}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v35}  ${wid[0]}

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${TODAY}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${TODAY}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v0}  ${wid[0]}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid_v1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c30}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c30}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY35}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c30}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c30}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  9                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid601}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid605}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date8}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid608}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid610}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date15}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid615}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date20}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid620}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date24}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid624}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date28}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid628}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
                    
    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid630}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    
    Set Test Variable  ${reportDateCategory2}      LAST_THIRTY_DAYS
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c30}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Token_Report-7
    [Documentation]  Generate NEXT_THIRTY_DAYS report of a provider for both online and walk-in checkin after changing waitlistMgr settings from TOKEN to CHECK-IN
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[0]}  onlineCheckIns=${bool[1]}  maxPartySize=1

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Add_DAY3}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable  ${Add_DAY3}
    ${Date3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date3}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY3}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v3}  ${wid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Add_DAY6}=  db.add_timezone_date  ${tz}  6  
    Set Suite Variable  ${Add_DAY6}
    ${Date6} =	Convert Date	${Add_DAY6}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date6}
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY6}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p6}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c30}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY35}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c30}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c30}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  10                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid601}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date3}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid603}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid605}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date8}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid608}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid610}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date15}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid615}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date20}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid620}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date24}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid624}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
                    

    Should Be Equal As Strings  ${Date28}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid628}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    Should Be Equal As Strings  ${jid_c30}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][9]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][9]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid630}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId
    

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c33}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY36}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c33}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c33}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  10                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid501}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid504}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date6}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid506}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid507}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid510}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date14}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid514}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date19}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid519}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date23}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid523}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date27}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid527}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    Should Be Equal As Strings  ${jid_c33}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][9]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][9]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid530}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    

JD-TC-Token_Report-UH1
    [Documentation]  Generate report without login
    
    ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${pcid23}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

    
JD-TC-Token_Report-UH2
    [Documentation]  Generate report of a provider using CONSUMER login
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid23}=  get_id  ${CUSERNAME23}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${pcid23}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

    
JD-TC-Token_Report-UH3
    [Documentation]  Generate Next_Week report of a provider using provider_own_consumerId as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Token_Report-8
    [Documentation]  Generate report of a provider after disable Queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}


    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERNAME20}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    

    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${V1SERVICE3}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v1_s3}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${v1_s3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${V1SERVICE3}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue3}=    FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   10  ${p1_l1}  ${p1_s3}  ${v1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}
    
  
    ${resp}=  AddCustomer  ${CUSERNAME35}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid35}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME35}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid35}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid35}  ${p1_s3}  ${p1_q3}  ${DAY}  ${desc}  ${bool[1]}  ${cid35} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid_p13}  ${wid[0]}

    ${virtualService2}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${CUSERNAME23}
    Set Suite Variable  ${virtualService2}
    


    ${resp}=  Provider Add To WL With Virtual Service  ${cid35}  ${v1_s3}  ${p1_q3}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService2}   ${cid35}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid_v13}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid_p13} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c35}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid_p13}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid_v13}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Queue  ${p1_q3}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  02s

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     TODAY
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c35}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
       
    # ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c35}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c35}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c35}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue3}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Completed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[1]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id801}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c35}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_name}           ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue3}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE3}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Completed              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  Phone in   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id802}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    


    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c35}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Token_Report-9
    [Documentation]  Generate TOKEN report of a provider using provider_Own_ConsumerId and QUEUE_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME38}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid38}=  get_id  ${CUSERNAME38}

    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY1}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p1}  ${wid[0]}

    ${Add_DAY4}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable  ${Add_DAY4}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY4}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p4}  ${wid[0]}

    ${Add_DAY7}=  db.add_timezone_date  ${tz}  7  
    Set Suite Variable  ${Add_DAY7}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY7}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p7}  ${wid[0]}

    ${Add_DAY10}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${Add_DAY10}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY10}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p10}  ${wid[0]}
  
    ${Add_DAY14}=  db.add_timezone_date  ${tz}  14
    Set Suite Variable  ${Add_DAY14}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY14}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p14}  ${wid[0]}

    ${Add_DAY19}=  db.add_timezone_date  ${tz}  19
    Set Suite Variable  ${Add_DAY19}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY19}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p19}  ${wid[0]}
    
    ${Add_DAY23}=  db.add_timezone_date  ${tz}  23
    Set Suite Variable  ${Add_DAY23}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY23}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p23}  ${wid[0]}

    ${Add_DAY27}=  db.add_timezone_date  ${tz}  27
    Set Suite Variable  ${Add_DAY27}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY27}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p27}  ${wid[0]}
   
    ${Add_DAY30}=  db.add_timezone_date  ${tz}  30
    Set Suite Variable  ${Add_DAY30}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY30}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p30}  ${wid[0]}

    ${Add_DAY31}=  db.add_timezone_date  ${tz}  31
    Set Suite Variable  ${Add_DAY31}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY31}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p31}  ${wid[0]}
    
    ${Add_DAY36}=  db.add_timezone_date  ${tz}  36
    Set Suite Variable  ${Add_DAY36}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${Add_DAY36}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p36}  ${wid[0]}

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TODAY}  ${p1_s1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_p0}  ${wid[0]}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid_p1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c38}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}


    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS

    ${jid1_c38}=  Convert To String  ${jid_c38} 
    ${p1_q11}=  Convert To String  ${p1_q1} 
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid1_c38}   queue-eq=${p1_q11}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY36}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c38}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c38}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  9                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid501}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid504}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid507}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid510}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date14}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid514}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date19}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid519}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date23}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid523}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date27}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid527}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid530}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    
    ${jid1_c38}=  Convert To String  ${jid_c38} 
    ${p1_q21}=  Convert To String  ${p1_q2} 
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid1_c38}   queue-eq=${p1_q21}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
    
    sleep  10s
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY36}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c38}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c38}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}


JD-TC-Token_Report-UH4
    [Documentation]  Generate TOKEN report of a provider when DATE_RANGE is EMPTY
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${ENTER_DATE}


JD-TC-Token_Report-UH5
    [Documentation]  Generate TOKEN report of a provider when DATE_RANGE is invalid format
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${EMPTY}   date-le=${EMPTY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}

    ${date_dd_mm_yyyy} =	Convert Date	${TODAY}	result_format=%d-%m-%Y

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${date_dd_mm_yyyy}   date-le=${date_dd_mm_yyyy}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${date_dd_mm_yyyy}   date-le=${TODAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}


JD-TC-Token_Report-UH6
    [Documentation]  Generate TOKEN report of a provider when start and end of DATE_RANGE is Future
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${Add_DAY1}   date-le=${Add_DAY36}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}


JD-TC-Token_Report-UH7
    [Documentation]  Generate TOKEN report of a provider when DATE_RANGE is From current_date to Future_date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${TODAY}   date-le=${Add_DAY36}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}


JD-TC-Token_Report-UH8
    [Documentation]  Generate TOKEN report of a provider when DATE_RANGE is From Past_date to Future_date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${YESTERDAY}=  db.subtract_timezone_date  ${tz}   1
    Set Suite Variable  ${YESTERDAY}
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${YESTERDAY}   date-le=${Add_DAY1}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}


JD-TC-Token_Report-UH9
    [Documentation]  Generate TOKEN report of a provider when DATE_RANGE is greater than 90_days
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${Add_DAY91}=  db.add_timezone_date  ${tz}  92
    Set Suite Variable  ${Add_DAY91}
    ${Date91} =	Convert Date	${Add_DAY91}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date91}
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${TODAY}   date-le=${Add_DAY91}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}

    ${Sub_Date92}=  db.subtract_timezone_date  ${tz}   92
    Set Suite Variable  ${Sub_Date92}
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${Sub_Date92}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${MAX_DATE_RANGE}


JD-TC-Token_Report-UH10
    [Documentation]  Generate TOKEN report for a provider when start_date is greater than end_date of DATE_RANGE 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${TODAY}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${DATE_MISMATCH}

    ${Sub_Date10}=  db.subtract_timezone_date  ${tz}   10
    Set Suite Variable  ${Sub_Date10}

    ${Sub_Date20}=  db.subtract_timezone_date  ${tz}   20
    Set Suite Variable  ${Sub_Date20}

    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${Sub_Date10}   date-le=${Sub_Date20}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${DATE_MISMATCH}


JD-TC-Token_Report-UH11
    [Documentation]  Generate TOKEN report of a provider when start_date is FUTURE and end_date is PAST for DATE_RANGE
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${Add_DAY1}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}


JD-TC-Token_Report-UH12
    [Documentation]  Generate TOKEN report of a provider when start_date is FUTURE and end_date is Current_Day for DATE_RANGE
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${Add_DAY1}   date-le=${TODAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}



JD-TC-Token_Report-UH13
    [Documentation]  Generate TOKEN report of a provider when start_date is greater than end_date, and DATE_RANGE is FUTURE
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   date-ge=${Add_DAY36}   date-le=${Add_DAY1}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}

    

JD-TC-Token_Report-10
    [Documentation]  Generate TOKEN report of a provider using provider_Own_ConsumerId and QUEUE_id
    ${resp}=  Consumer Login  ${CUSERNAME38}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY1}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v11}  ${wid[0]}

    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY5}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v15}  ${wid[0]}

    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY8}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v18}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Set Test Variable  ${status-eq}               SUCCESS
    # Set Test Variable  ${reportType}              TOKEN
    # Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS
    # ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c38}   queue-eq=${p1_q1}
    # ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS

    ${jid1_c38}=  Convert To String  ${jid_c38} 
    ${p1_q11}=  Convert To String  ${p1_q1} 
    ${p1_s11}=  Convert To String  ${p1_s1} 
    ${v1_s11}=  Convert To String  ${v1_s1} 
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid1_c38}  queue-eq=${p1_q11}   service-eq=${p1_s11},${v1_s11}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  4s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY36}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c38}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c38}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  9                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid501}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid504}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid507}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid510}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date14}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid514}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date19}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid519}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date23}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid523}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date27}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid527}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue1}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid530}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    
    ${jid1_c38}=  Convert To String  ${jid_c38} 
    ${p1_q21}=  Convert To String  ${p1_q2} 
    ${p1_s11}=  Convert To String  ${p1_s1} 
    ${v1_s11}=  Convert To String  ${v1_s1} 
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid1_c38}  queue-eq=${p1_q21}   service-eq=${p1_s11},${v1_s11}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY36}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c38}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c38}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  3                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid381}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid385}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date8}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c38}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid388}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    


JD-TC-Token_Report-11
    [Documentation]  Generate NEXT_THIRTY_DAYS report of a provider for both online and walk-in checkin For any VIRTUAL SERVICE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME39}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid39}=  get_id  ${CUSERNAME39}

    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY1}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v1}  ${wid[0]}

    ${Add_DAY5}=  db.add_timezone_date  ${tz}  5  
    Set Suite Variable  ${Add_DAY5}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY5}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v5}  ${wid[0]}

    ${Add_DAY8}=  db.add_timezone_date  ${tz}  8  
    Set Suite Variable  ${Add_DAY8}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY8}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v8}  ${wid[0]}

    ${Add_DAY10}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${Add_DAY10}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY10}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v10}  ${wid[0]}
  
    ${Add_DAY15}=  db.add_timezone_date  ${tz}  15  
    Set Suite Variable  ${Add_DAY15}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY15}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v15}  ${wid[0]}

    ${Add_DAY20}=  db.add_timezone_date  ${tz}  20
    Set Suite Variable  ${Add_DAY20}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY20}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v20}  ${wid[0]}
    
    ${Add_DAY24}=  db.add_timezone_date  ${tz}  24
    Set Suite Variable  ${Add_DAY24}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY24}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v24}  ${wid[0]}

    ${Add_DAY28}=  db.add_timezone_date  ${tz}  28
    Set Suite Variable  ${Add_DAY28}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY28}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v28}  ${wid[0]}
   
    ${Add_DAY30}=  db.add_timezone_date  ${tz}  30
    Set Suite Variable  ${Add_DAY30}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY30}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v30}  ${wid[0]}

    ${Add_DAY31}=  db.add_timezone_date  ${tz}  31
    Set Suite Variable  ${Add_DAY31}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY31}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v31}  ${wid[0]}
    
    ${Add_DAY35}=  db.add_timezone_date  ${tz}  35
    Set Suite Variable  ${Add_DAY35}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${Add_DAY35}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v35}  ${wid[0]}

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${TODAY}
    ${consumerNote1}=   FakerLibrary.word
    ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${p1_q2}  ${TODAY}  ${v1_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService1}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid_v0}  ${wid[0]}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${cwid_v1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jid_c39}   ${resp.json()['waitlistingFor'][0]['memberJaldeeId']}

    
    Set Test Variable  ${status-eq}               SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}     NEXT_THIRTY_DAYS
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c39}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Not Contain    ${resp.json()}  ${TODAY}
    Should Not Contain    ${resp.json()}  ${Add_DAY31}
    Should Not Contain    ${resp.json()}  ${Add_DAY35}
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c39}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c39}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  9                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}              ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid601}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][1]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid605}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date8}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][2]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid608}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date10}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][3]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid610}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date15}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][4]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid615}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date20}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][5]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid620}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date24}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][6]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid624}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId
    
    Should Be Equal As Strings  ${Date28}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][7]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid628}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId
                    

    Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c39}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${p1queue2}        ${resp.json()['reportContent']['data'][8]['5']}  # Queue
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Checked In              ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_cid630}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId
    


    # Set Test Variable  ${reportDateCategory2}      LAST_THIRTY_DAYS
    # ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c39}   
    # ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Token_Report-13
    [Documentation]  Token report before completing prepayment of a Physical service (Independent_SP)
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+5810531
    Set Suite Variable   ${PUSERPH0}
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}



    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    true
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p0_id}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${p0_id}
    # ${pid}=  get_acc_id  ${PUSERPH0}
    # Set Suite Variable  ${pid}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  15  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=15  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}
    

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}


    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERPH0}
    Set Suite Variable   ${ZOOM_id0}


    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

   
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE2}   ${desc}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}   ${bool[1]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v1_sid1}  ${resp.json()} 

    ${queue1}=    FakerLibrary.word
    Set Suite Variable  ${queue1}
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}   1   30
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${v1_sid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    # ${resp}=  AddCustomer  ${CUSERNAME15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid15}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid15}  ${resp.json()[0]['id']}
    # Set Suite Variable  ${jid_c15}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${p0_id}  ${p1_qid}  ${DAY1}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${pre_amount1}=  twodigitfloat  ${min_pre1}
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount1}=  Convert To twodigitfloat  ${balamount}
    Set Suite Variable  ${balamount1}

    # # ${balamount1}=  Convert To Number  ${balamount}  2
    # ${balamount1}=  twodigitfloat  ${balamount}
    # Set Suite Variable  ${balamount1}
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p0_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    # Should Be Equal As Strings   ${resp.json()['consumer']['jaldeeId']}  ${jid_c15}

    ${resp}=   Encrypted Provider Login   ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}  ${resp.json()[0]['id']}
    Set Suite Variable  ${jid_c15}  ${resp.json()[0]['jaldeeId']}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             TOKEN
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c15}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep   02s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c27_1}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c15}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data

# *** comment ***
JD-TC-Verify-1-Token_Report-13  
    [Documentation]  Token report after completing prepayment of a Physical service (Independent_SP)
    
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${p0_id}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref_pre1}   ${resp.json()['paymentRefId']}
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${p0_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${p0_id}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref_pre1} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${p0_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[1]}
    Set Suite Variable  ${c15_BillId1}      ${resp.json()['billId']}
    # Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}  amountDue=${balamount1}    totalTaxAmount=${tax}
   
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p0_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}

    #  ##################################################################################
    ${resp}=   Encrypted Provider Login   ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}      TODAY
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c15}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    sleep   02s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c27_2}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c15}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Current_Date}        ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c15}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Partially paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id19-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

    #  ##################################################################################
JD-TC-Verify-2-Token_Report-13
    [Documentation]  Token report after completing Fullpayment of a Physical service (Independent_SP)

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${p0_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    Set Test variable   ${resp.json()['amountDue']}   ${balamount1}   

    sleep  2s
    ${resp}=  Make payment Consumer Mock  ${p0_id}  ${balamount1}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_balance1}   ${resp.json()['paymentRefId']}
    
    ${resp}=  Get Payment Details  account-eq=${p0_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${balamount1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${p0_id}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref_balance1} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[1]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}   ${p0_id}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}   ${payref_pre1} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}   ${purpose[0]}


    ${resp}=   Encrypted Provider Login   ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}
    
    sleep  2s
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              TOKEN
    Set Test Variable  ${reportDateCategory1}      TODAY
    ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c15}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable   ${token_id1}   ${resp.json()}
    
    sleep   02s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c27_3}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c15}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Current_Date}        ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c15}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
    Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Fully paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id19-3}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

JD-TC-Verify-3-Token_Report-13

    [Documentation]  Token report When cancel waitlist after completing Full payment of a Physical service (Independent_SP)

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=   Encrypted Provider Login   ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${msg}=  Fakerlibrary.word
    ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[2]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}    paymentStatus=${paymentStatus[3]}
    
        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY
        ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c15}   
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep   02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c27_3}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c15}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}        ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${jid_c15}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
        # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
        Should Be Equal As Strings  ${queue1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
        Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
        Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
        Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
        Set Suite Variable  ${conf_id19-3}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    


JD-TC-Token_Report-14
    
    [Documentation]  Token report before completing prepayment of a Physical service (BRANCH)
        ${resp}=  Encrypted Provider Login  ${MUSERNAME23}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
        ${pid_B28}=  get_acc_id  ${MUSERNAME23}
        Set Suite variable  ${pid_B28}

        clear_Department    ${MUSERNAME23}
        clear_service       ${MUSERNAME23}
        clear_location      ${MUSERNAME23}

        ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
        Should Be Equal As Strings  ${resp.status_code}  200
   
        ${resp}=  View Waitlist Settings
        Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}
      
        ${highest_package}=  get_highest_license_pkg
        Log  ${highest_package}
        Set Suite variable  ${lic2}  ${highest_package[0]}
        ${resp}=   Change License Package  ${highest_package[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
       
        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Enable Tax
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Toggle Department Enable
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${dep_id}  ${resp.json()}
    
        ${number}=  Random Int  min=1000  max=2000
        ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
        clear_users  ${PUSERNAME_U1}
        Set Suite Variable  ${PUSERNAME_U1}
        ${firstname}=  FakerLibrary.name
        Set Suite Variable  ${firstname}
        ${lastname}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname}
        ${dob}=  FakerLibrary.Date
        Set Suite Variable  ${dob}
        ${pin}=  get_pincode
        Set Suite Variable  ${pin}

        ${resp}=  Get User
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${iscorp_subdomains}=  get_iscorp_subdomains  1
        Log  ${iscorp_subdomains}
        ${length}=  Get Length  ${iscorp_subdomains}
        FOR  ${i}  IN RANGE  ${length}
            Set Test Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
            Set Test Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
            Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
        END
 


        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id}  ${resp.json()}
        ${resp}=  Get User
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
        Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7

        Set Suite Variable  ${list}
        ${sTime1}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  2  00  
        Set Suite Variable   ${eTime1}
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${description}=  FakerLibrary.sentence
        ${dur}=  FakerLibrary.Random Int  min=10  max=20
        ${amt}=  FakerLibrary.Random Int  min=200  max=500
        ${min_pre1}=  FakerLibrary.Random Int  min=200  max=${amt}
        Set Suite Variable  ${min_pre1}
        ${totalamt}=  Convert To Number  ${amt}  1
        Set Suite Variable  ${totalamt}
        ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
        Set Suite Variable  ${balamount}
        ${pre_float2}=  twodigitfloat  ${min_pre1}
        Set Suite Variable  ${pre_float2}
        ${pre_float1}=  Convert To Number  ${min_pre1}  1
        Set Suite Variable  ${pre_float1}

        ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre1}  ${totalamt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id}  ${resp.json()}
        ${queue_name1}=  FakerLibrary.name
        Set Suite Variable  ${queue_name1}
        ${resp}=  Create Queue For User  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id28}  ${resp.json()}

        # ${resp}=  AddCustomer  ${CUSERNAME17}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${pcid17}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid27}  ${resp.json()[0]['id']}
        # Set Suite Variable  ${jid_c27}  ${resp.json()[0]['jaldeeId']}

        ${resp}=  ProviderLogout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${resp}=  Add To Waitlist Consumer For User  ${pid_B28}  ${que_id28}  ${CUR_DAY}  ${s_id}  ${msg}  ${bool[0]}  ${u_id}  0
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid_C17}  ${wid[0]} 

        ${resp}=  Get consumer Waitlist By Id  ${cwid_C17}  ${pid_B28}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    
        ${resp}=  Encrypted Provider Login  ${MUSERNAME23}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid27}  ${resp.json()[0]['id']}
        Set Suite Variable  ${jid_c27}  ${resp.json()[0]['jaldeeId']}

        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY
        ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c27}   
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep   02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c27_1}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c27}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

JD-TC-Verify-1-Token_Report-14
        [Documentation]  Token report after completing prepayment of a Physical service (BRANCH)
        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${cid27}=  get_id  ${CUSERNAME17}
        
        ${resp}=  Make payment Consumer Mock  ${pid_B28}  ${min_pre1}  ${purpose[0]}  ${cwid_C17}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid27}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid_C17}  ${pid_B28}  ${purpose[0]}  ${cid27}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
        sleep  04s
        ${resp}=  Get Payment Details  account-eq=${pid_B28}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1}
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid_B28}
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid_C17}
        Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

        ${resp}=  ConsumerLogout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Encrypted Provider Login   ${MUSERNAME23}  ${PASSWORD} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${cwid_C17}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  ProviderLogout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get Bill By consumer  ${cwid_C17}  ${pid_B28}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  uuid=${cwid_C17}  netTotal=${totalamt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}   totalAmountPaid=${pre_float1}  amountDue=${balamount}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME23}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY
        ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c27}   
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep   02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c27_2}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c27}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${jid_c27}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
        # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
        Should Be Equal As Strings  ${queue_name1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
        Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
        Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
        Should Be Equal As Strings  Partially paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
        Set Suite Variable  ${conf_id19-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
        
JD-TC-Verify-2-Token_Report-14
    [Documentation]  Token report When consumer cancel waitlist after completing prepayment of a Physical service (BRANCH) 
        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id  ${cwid_C17}  ${pid_B28}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}


        ${resp}=  Cancel Waitlist  ${cwid_C17}  ${pid_B28} 
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   02s
      
        ${resp}=  Encrypted Provider Login  ${MUSERNAME23}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY
        ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c27}   
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep   02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c27_3}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c27}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}        ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${jid_c27}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
        # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
        Should Be Equal As Strings  ${queue_name1}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
        Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
        Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
        Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
        Set Suite Variable  ${conf_id19-3}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    


JD-TC-Token_Report-15
        [Documentation]  Token report before completing prepayment of a Virtual service (BRANCH)
        
        ${resp}=  Encrypted Provider Login  ${MUSERNAME21}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
        ${pid_B5}=  get_acc_id  ${MUSERNAME21}
        Set Suite variable  ${pid_B5}


        clear_Department    ${MUSERNAME21}
        clear_service       ${MUSERNAME21}
        clear_location      ${MUSERNAME21}

        ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
        Should Be Equal As Strings  ${resp.status_code}  200
   
        ${resp}=  View Waitlist Settings
        Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}
    
    
        ${highest_package}=  get_highest_license_pkg
        Log  ${highest_package}
        Set Suite variable  ${lic2}  ${highest_package[0]}
        ${resp}=   Change License Package  ${highest_package[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Enable Tax
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Toggle Department Enable
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${dep_id}  ${resp.json()}
    
        # ${number}=  Random Int  min=100  max=200
        ${PUSERNAME_U32}=  Evaluate  ${MUSERNAME21}+7654321
        clear_users  ${PUSERNAME_U32}
        Set Suite Variable  ${PUSERNAME_U32}
        ${firstname}=  FakerLibrary.name
        Set Suite Variable  ${firstname}
        ${lastname}=  FakerLibrary.last_name
        Set Suite Variable  ${lastname}
        ${dob}=  FakerLibrary.Date
        Set Suite Variable  ${dob}
    
        ${resp}=  Get User
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${iscorp_subdomains}=  get_iscorp_subdomains  1
        Log  ${iscorp_subdomains}
        ${length}=  Get Length  ${iscorp_subdomains}
        FOR  ${i}  IN RANGE  ${length}
                Set Test Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
                Set Test Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
                Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
                Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
        END
 


        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U32}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U32}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U32}  ${countryCodes[0]}  ${PUSERNAME_U32}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${u_id32}  ${resp.json()}
        ${resp}=  Get User
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${p1_id32}   ${resp.json()[0]['id']}
        Set Suite Variable   ${p0_id32}   ${resp.json()[1]['id']}
    
        # ${resp}=  Enable Disable Virtual Service  Enable
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME21}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${MUSERNAME21}   status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Virtual Calling Mode
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${MUSERNAME21}
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
        Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

        ${PUSERPH_id0}=  Evaluate  ${MUSERNAME21}+10101
        ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
        Set Suite Variable   ${ZOOM_Pid0}


        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
        
        ${amt_V1}=   Random Int   min=100   max=500
        ${min_pre_V1}=   Random Int   min=10   max=50
        ${min_pre1_V1}=  Convert To Number  ${min_pre_V1}  1
        ${totalamt_V1}=  Convert To Number  ${amt_V1}  1
        ${balamount_V1}=  Evaluate  ${totalamt_V1}-${min_pre1_V1}
        ${pre_float2_V1}=  twodigitfloat  ${min_pre1_V1}
        ${pre_float1_V1}=  Convert To Number  ${min_pre1_V1}  1
        ${description}=    FakerLibrary.word

        Set Suite Variable  ${amt_V1}
        Set Suite Variable  ${min_pre_V1}
        Set Suite Variable  ${min_pre1_V1}
        Set Suite Variable  ${totalamt_V1}
        Set Suite Variable  ${balamount_V1}
        Set Suite Variable  ${pre_float2_V1}
        Set Suite Variable  ${pre_float1_V1}

        Set Test Variable  ${vstype}  ${vservicetype[1]}
        ${resp}=  Create Virtual Service For User  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1_V1}  ${totalamt_V1}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}  ${u_id32}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${VS_id1}  ${resp.json()} 
        ${resp}=   Get Service By Id  ${VS_id1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log  ${resp.json()}
        Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1_V1}  totalAmount=${totalamt_V1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
        

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7

        Set Suite Variable  ${list}
      # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  2  00  
        Set Suite Variable   ${eTime1}
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${description2}=  FakerLibrary.sentence
        ${dur2}=  FakerLibrary.Random Int  min=10  max=20
        ${amt2}=  FakerLibrary.Random Int  min=200  max=500
        ${min2_pre1}=  FakerLibrary.Random Int  min=200  max=${amt2}
        Set Suite Variable  ${min2_pre1}
        ${totalamt2}=  Convert To Number  ${amt2}  1
        Set Suite Variable  ${totalamt2}
        ${balamount2}=  Evaluate  ${totalamt2}-${min2_pre1}
        Set Suite Variable  ${balamount2}
        ${pre2_float2}=  twodigitfloat  ${min2_pre1}
        Set Suite Variable  ${pre2_float2}
        ${pre2_float1}=  Convert To Number  ${min2_pre1}  1
        Set Suite Variable  ${pre2_float1}

        ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur2}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min2_pre1}  ${totalamt2}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id32}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${NS_id1}  ${resp.json()}
        ${queue_name2}=  FakerLibrary.name
        Set Suite Variable  ${queue_name2}
        ${resp}=  Create Queue For User  ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id32}  ${VS_id1}  ${NS_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${que_id32}  ${resp.json()}
      
        # ${resp}=  AddCustomer  ${CUSERNAME17}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid17}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid17}  ${resp.json()[0]['id']}
        # Set Suite Variable  ${jid_c17}  ${resp.json()[0]['jaldeeId']}

        ${resp}=  ProviderLogout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${JC_c17}=  get_id  ${CUSERNAME17}
        Set Suite Variable  ${JC_c17}

        ${USERPH1_id}=  Evaluate  ${CUSERNAME17}+10001
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${USERPH1_id}

        Set Suite Variable  ${ZOOM_id}    ${ZOOM_Pid1}
        Set Suite Variable  ${WHATSAPP_id}   ${USERPH1_id}
        ${virtualService}=  Create Dictionary  ${CallingModes[0]}=${ZOOM_id}
    
        ${msg}=  FakerLibrary.word
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable   ${CUR_DAY}
        ${resp}=  Consumer Add To WL With Virtual Service For User  ${pid_B5}  ${que_id32}  ${CUR_DAY}  ${VS_id1}  ${msg}  ${bool[0]}  ${virtualService}   ${u_id32}  0
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200    
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid_C27}  ${wid[0]}
        ${resp}=  Get consumer Waitlist By Id   ${cwid_C27}  ${pid_B5}   
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}   partySize=1   waitlistedBy=CONSUMER
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE4}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${VS_id1}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${JC_c17}
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id32}
        

        ${resp}=  Get consumer Waitlist By Id  ${cwid_C27}  ${pid_B5}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME21}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid17}  ${resp.json()[0]['id']}
        Set Suite Variable  ${jid_c17}  ${resp.json()[0]['jaldeeId']}

        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY
        # ${filter1}=  Create Dictionary   queue-eq=${que_id32}
        ${filter1}=  Create Dictionary   waitlistingForId-eq=${jid_c17}
           
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep  02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c17}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

JD-TC-Verify-1-Token_Report-15
        [Documentation]  Token report after completing prepayment of a Virtual service (BRANCH)
        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Make payment Consumer Mock  ${pid_B5}  ${min_pre1_V1}  ${purpose[0]}  ${cwid_C27}  ${VS_id1}  ${bool[0]}   ${bool[1]}  ${JC_c17}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=  Make payment Consumer Mock  ${min_pre1_V1}  ${bool[1]}  ${cwid_C27}  ${pid_B5}  ${purpose[0]}  ${cid17}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
        sleep  02s
        ${resp}=  Get Payment Details  account-eq=${pid_B5}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1_V1}
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid_B5}
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid_C27}
        Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

        ${resp}=  ConsumerLogout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Encrypted Provider Login   ${MUSERNAME21}  ${PASSWORD} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${cwid_C27}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  ProviderLogout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By consumer  ${cwid_C27}  ${pid_B5}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${cwid_C27}  netTotal=${totalamt_V1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt_V1}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1_V1}  amountDue=${balamount_V1}

        ${resp}=  Get consumer Waitlist By Id  ${cwid_C27}  ${pid_B5}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}


        ${resp}=  Encrypted Provider Login  ${MUSERNAME21}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY

        ${jid1_c17}=  Convert To String  ${jid_c17} 
        ${filter}=  Create Dictionary   waitlistingForId-eq=${jid1_c17}   
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep  02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c17}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}        ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${jid_c17}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
        # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
        Should Be Equal As Strings  ${queue_name2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
        Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
        Should Be Equal As Strings  Checked In   ${resp.json()['reportContent']['data'][0]['8']}  # Status
        Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
        Should Be Equal As Strings  Partially paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
        Set Suite Variable  ${conf_id20-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    

JD-TC-Verify-2-Token_Report-15
        [Documentation]  Token report When cancel waitlist after completing prepayment of a virtual service (BRANCH) 
        ${resp}=  Encrypted Provider Login  ${MUSERNAME21}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${msg}=  Fakerlibrary.word
        ${resp}=  Waitlist Action Cancel  ${cwid_C27}  ${waitlist_cancl_reasn[2]}   ${msg}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  02s

        ${resp}=  Get Waitlist By Id  ${cwid_C27} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]}   paymentStatus=${paymentStatus[3]}   partySize=1   waitlistedBy=CONSUMER 

        Set Test Variable  ${status-eq}              SUCCESS
        Set Test Variable  ${reportType}              TOKEN
        Set Test Variable  ${reportDateCategory1}      TODAY
        ${filter}=  Create Dictionary   waitlistingForId-eq=${jid_c17}   
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id1}   ${resp.json()}
    
        sleep  02s
        ${resp}=  Get Report Status By Token Id  ${token_id1}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
        # Should Be Equal As Strings  ${jid_c17}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Token Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}        ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${jid_c17}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
        # Should Be Equal As Strings  ${C8_fname}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
        Should Be Equal As Strings  ${queue_name2}        ${resp.json()['reportContent']['data'][0]['5']}  # Queue
        Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
        Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
        Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
        Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
        Set Suite Variable  ${conf_id20-3}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    



***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}



    