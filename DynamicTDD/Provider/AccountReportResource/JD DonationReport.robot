*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Donation Report
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
@{multiples}  10  20  30   40   50
${SERVICE1}   SERVICE1
${a}   0
${digits}     0123456789
${self}       0
${start}      100


*** Test Cases ***

JD-TC-Donation_Report-1
        [Documentation]   Generate DONATION report using Donation amount
        ${resp}=   Billable Domain Providers

        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${min_don_amt}=   Random Int   min=10   max=50
        ${min_don_amt}=   Evaluate  ${min_don_amt}*${multiples[0]}
        ${max_don_amt}=   Random Int   min=1000   max=5000
        ${max_don_amt}=   Evaluate  ${max_don_amt}*${multiples[0]}
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=500   max=1000
        ${total_amnt1}=  Convert To Number  ${total_amnt}  1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt1}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME22}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${d_fname}=    FakerLibrary.word
        Set Suite Variable   ${d_fname}
        ${d_lname}=    FakerLibrary.word
        Set Suite Variable   ${d_lname}
        Set Suite Variable   ${Donor_name}    ${d_fname} ${d_lname}
        ${con_id}=  get_id  ${CUSERNAME22}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}
        Set Suite Variable  ${don_amt}
        ${don_amt_float}=  twodigitfloat  ${don_amt}
        Set Suite Variable  ${don_amt_float}
        ${Donation_amt}=  commaformatNumber  ${don_amt}
        Set Suite Variable  ${Donation_amt}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${d_fname}  ${d_lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}

        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=  Make payment Consumer Mock  ${don_amt}  ${bool[1]}  ${don_id}  ${acc_id}  ${purpose[5]}  ${con_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
        
        Log  ${PUSERNAME}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Bill By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=  Get Payment By UUId  ${don_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${pay_id}  ${resp.json()[0]['id']}

        # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt} 
        # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY 


        # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

        # Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()[1]['status']}  ${cupnpaymentStatus[0]}  
        # Should Be Equal As Strings  ${resp.json()[1]['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${don_amt} 
        # Should Be Equal As Strings  ${resp.json()[1]['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}  ${payment_modes[5]}  
        # Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()[1]['paymentGateway']}  RAZORPAY  

        # sleep  02s
        # ${resp}=  Get Payment By Individual  ${pay_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[0]}  
        # Should Be Equal As Strings  ${resp.json()['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()['amount']}  ${don_amt}
        # Should Be Equal As Strings  ${resp.json()['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()['paymentMode']}  ${payment_modes[5]}  
        # Should Be Equal As Strings  ${resp.json()['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()['paymentGateway']}  RAZORPAY 

        ${Current_Date} =	Convert Date	${CUR_DAY}	result_format=%d/%m/%Y
        Set Suite Variable  ${Current_Date}

        Set Test Variable  ${paymentPurpose-eq2}      donation
        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      TODAY
        ${don_amt11}=  Convert To String  ${don_amt} 
        ${filter2}=  Create Dictionary   donationAmount-eq=${don_amt}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id}   ${resp.json()}
        # sleep  04s
        ${resp}=  Get Report Status By Token Id  ${token_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId1_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id101}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
        

JD-TC-Donation_Report-2
        [Documentation]   Generate DONATION report using service id
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      TODAY
        ${sid11}=  Convert To String  ${sid1}  
        ${filter2}=  Create Dictionary   service-eq=${sid11}
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${token_id}   ${resp.json()}
        # sleep  04s
        ${resp}=  Get Report Status By Token Id  ${token_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId2_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                   ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id201}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
    
        
JD-TC-Donation_Report-UH1
    [Documentation]  Generate DONATION report without login
    
    ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   service-eq=${sid1}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}

    
JD-TC-Donation_Report-UH2
    [Documentation]  Generate DONATION report of a provider using CONSUMER login
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid23}=  get_id  ${CUSERNAME23}

    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   donationAmount-eq=${don_amt}    
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

    
JD-TC-Donation_Report-UH3
    [Documentation]  Generate DONATION report of a provider using service as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK 
    ${filter1}=  Create Dictionary   service-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Donation_Report-UH4
    [Documentation]  Generate DONATION report of a provider using donation_Amount as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter2}=  Create Dictionary   donationAmount-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Donation_Report-UH5
    [Documentation]  Generate DONATION report of a provider using FirstName of Donor as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory3}      TODAY
    ${filter3}=  Create Dictionary   firstName-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory3}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Donation_Report-UH6
    [Documentation]  Generate DONATION report of a provider when DATE_RANGE is invalid format
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   date-ge=${EMPTY}   date-le=${EMPTY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}

    ${date_dd_mm_yyyy} =	Convert Date	${CUR_DAY}	result_format=%d-%m-%Y

    ${filter}=  Create Dictionary   date-ge=${date_dd_mm_yyyy}   date-le=${date_dd_mm_yyyy}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}

    ${filter}=  Create Dictionary   date-ge=${date_dd_mm_yyyy}   date-le=${CUR_DAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE}


JD-TC-Donation_Report-UH7
    [Documentation]  Generate DONATION report of a provider when start and end of DATE_RANGE is Future
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${Add_DAY36}=  db.add_timezone_date  ${tz}  36
    Set Suite Variable  ${Add_DAY36}
    ${filter}=  Create Dictionary   date-ge=${Add_DAY1}   date-le=${Add_DAY36}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}


JD-TC-Donation_Report-UH8
    [Documentation]  Generate DONATION report of a provider when DATE_RANGE is From current_date to Future_date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    
    ${filter}=  Create Dictionary   date-ge=${CUR_DAY}   date-le=${Add_DAY36}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}


JD-TC-Donation_Report-UH9
    [Documentation]  Generate DONATION report of a provider when DATE_RANGE is From Past_date to Future_date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${YESTERDAY}=  db.subtract_timezone_date  ${tz}   1
    Set Suite Variable  ${YESTERDAY}
    ${filter}=  Create Dictionary   date-ge=${YESTERDAY}   date-le=${Add_DAY1}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}


JD-TC-Donation_Report-UH10
    [Documentation]  Generate DONATION report of a provider when DATE_RANGE is greater than 90_days
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${Add_DAY92}=  db.add_timezone_date  ${tz}  92
    Set Suite Variable  ${Add_DAY92}
    ${filter}=  Create Dictionary   date-ge=${CUR_DAY}   date-le=${Add_DAY92}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}

    ${Sub_Date92}=  db.subtract_timezone_date  ${tz}   92
    Set Suite Variable  ${Sub_Date92}
    ${filter}=  Create Dictionary   date-ge=${Sub_Date92}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${MAX_DATE_RANGE}


JD-TC-Donation_Report-UH11
    [Documentation]  Generate DONATION report for a provider when start_date is greater than end_date of DATE_RANGE 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   date-ge=${CUR_DAY}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${DATE_MISMATCH}

    ${Sub_Date10}=  db.subtract_timezone_date  ${tz}   10
    Set Suite Variable  ${Sub_Date10}

    ${Sub_Date20}=  db.subtract_timezone_date  ${tz}   20
    Set Suite Variable  ${Sub_Date20}

    ${filter}=  Create Dictionary   date-ge=${Sub_Date10}   date-le=${Sub_Date20}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${DATE_MISMATCH}


JD-TC-Donation_Report-UH12
    [Documentation]  Generate DONATION report of a provider when start_date is FUTURE and end_date is PAST for DATE_RANGE
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   date-ge=${Add_DAY1}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}


JD-TC-Donation_Report-UH13
    [Documentation]  Generate DONATION report of a provider when start_date is FUTURE and end_date is Current_Day for DATE_RANGE
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   date-ge=${Add_DAY1}   date-le=${CUR_DAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}



JD-TC-Donation_Report-UH14
    [Documentation]  Generate DONATION report of a provider when start_date is greater than end_date, and DATE_RANGE is FUTURE
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   date-ge=${Add_DAY36}   date-le=${Add_DAY1}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}

    


*** Keywords ***
Billable Domain Providers
    [Arguments]  ${min}=150   ${max}=260
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${min}   ${max}
            
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Suite Variable  ${PUSERNAME_PH}  ${decrypted_data['primaryPhoneNumber']}
        # Set Suite Variable  ${PUSERNAME_PH}  ${resp.json()['primaryPhoneNumber']}
        clear_location   ${PUSERNAME${a}}
        clear_service    ${PUSERNAME${a}}
        ${acc_id}=  get_acc_id  ${PUSERNAME${a}}
        Set Suite Variable   ${acc_id}
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

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

        ${resp}=  View Waitlist Settings
	    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME${a}}
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   clear_service       ${PUSERNAME${a}}
        Exit For Loop IF     '${check}' == 'True'

    END  



*** Comments ***

JD-TC-Donation_Report-3
        [Documentation]   Generate DONATION report using Name of Donor
        ${resp}=   Consumer Login  ${CUSERNAME22}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${d_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}   ${d_lname}
        Should Be Equal As Strings  ${resp.json()['service']['id']}       ${sid1}
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      TODAY
        ${filter2}=  Create Dictionary   firstName-eq=${Donor_name}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId2_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id301}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
    
