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
        [Documentation]   Generate Last_Week DONATION report using Donation amount
        ${resp}=   Billable
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
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${total_amnt1}  ${bool[1]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
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
        ${TODAY} =	Convert Date	${CUR_DAY}	result_format=%d/%m/%Y
        Set Suite Variable  ${TODAY}
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

        ${resp}=  Make payment Consumer  ${don_amt}  ${payment_modes[2]}  ${don_id}  ${acc_id}  ${purpose[5]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${don_amt_float} /></td>
        Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL22} /></td>
        Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME22} ></td>

        ${resp}=  Make payment Consumer Mock  ${don_amt}  ${bool[1]}  ${don_id}  ${acc_id}  ${purpose[5]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

        Log  ${PUSERNAME}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Payment By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_id}  ${resp.json()[1]['id']}
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[4]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[2]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  PAYUMONEY  

        Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[1]['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[1]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${don_amt} 
        Should Be Equal As Strings  ${resp.json()[1]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${acc_id}  
        Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[1]['paymentGateway']}  PAYUMONEY  

        ${resp}=  Get Payment By Individual  ${pay_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()['amount']}  ${don_amt}
        Should Be Equal As Strings  ${resp.json()['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()['accountId']}  ${acc_id}  
        Should Be Equal As Strings  ${resp.json()['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()['paymentGateway']}  PAYUMONEY 


        Set Test Variable  ${paymentPurpose-eq2}      donation
        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      TODAY
        ${filter2}=  Create Dictionary   donationAmount-eq=${don_amt}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId1_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id101}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
        
        ${LAST_WEEK_DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${LAST_WEEK_DAY1} 
        ${LAST_WEEK_DAY7}=  db.add_timezone_date  ${tz}  6  
        Set Suite Variable  ${LAST_WEEK_DAY7}

        change_system_date   7

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportDateCategory}      LAST_WEEK
        ${filter2}=  Create Dictionary   donationAmount-eq=${don_amt}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId1_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${LAST_WEEK_DAY1}               ${resp.json()['reportContent']['from']}
        Should Be Equal As Strings  ${LAST_WEEK_DAY7}               ${resp.json()['reportContent']['to']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id101}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
        
        resetsystem_time



JD-TC-Donation_Report-2
        [Documentation]   Generate Last_Thirty_days DONATION report using Donation amount
        resetsystem_time

        ${LAST_Month_DAY1}=  db.subtract_timezone_date  ${tz}   10
        Set Suite Variable  ${LAST_Month_DAY1} 
        ${LAST_Month_DAY30}=  db.add_timezone_date  ${tz}  19
        Set Suite Variable  ${LAST_Month_DAY30}

        change_system_date   20

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      LAST_THIRTY_DAYS
        ${filter2}=  Create Dictionary   donationAmount-eq=${don_amt}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId1_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Last 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${LAST_Month_DAY1}               ${resp.json()['reportContent']['from']}
        Should Be Equal As Strings  ${LAST_Month_DAY30}               ${resp.json()['reportContent']['to']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id201}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
    
        resetsystem_time


JD-TC-Donation_Report-3
        [Documentation]   Generate DATE_RANGE DONATION report using service id
        resetsystem_time

        ${StartDate}=  db.subtract_timezone_date  ${tz}   10
        ${EndDate}=  db.add_timezone_date  ${tz}  50 

        change_system_date   50

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      DATE_RANGE
        ${filter2}=  Create Dictionary   donationAmount-eq=${don_amt}   date-ge=${StartDate}   date-le=${EndDate} 
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId1_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Date Range       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${StartDate}               ${resp.json()['reportContent']['from']}
        Should Be Equal As Strings  ${EndDate}               ${resp.json()['reportContent']['to']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id201}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
        resetsystem_time



JD-TC-Donation_Report-4
        [Documentation]   Generate Last_Week DONATION report using service id
        resetsystem_time
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      TODAY
        ${filter2}=  Create Dictionary   service-eq=${sid1}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId2_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id201}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
        resetsystem_time


JD-TC-Donation_Report-5
        [Documentation]   Generate Last_Thirty_days DONATION report using service id
        resetsystem_time

        change_system_date   20

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      LAST_THIRTY_DAYS
        ${filter2}=  Create Dictionary   service-eq=${sid1}  
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId2_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Last 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${LAST_Month_DAY1}               ${resp.json()['reportContent']['from']}
        Should Be Equal As Strings  ${LAST_Month_DAY30}               ${resp.json()['reportContent']['to']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id201}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
    
        resetsystem_time




JD-TC-Donation_Report-6
        [Documentation]   Generate DATE_RANGE DONATION report using service id
        ${DAY1}=  db.subtract_timezone_date  ${tz}   10
        Set Suite Variable  ${DAY1} 
        ${DAY60}=  db.add_timezone_date  ${tz}  50 
        Set Suite Variable  ${DAY60}

        change_system_date   50

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        Set Test Variable  ${reportType}              DONATION
        Set Test Variable  ${reportDateCategory}      DATE_RANGE
        ${filter2}=  Create Dictionary   service-eq=${sid1}   date-ge=${DAY1}   date-le=${DAY60} 
        ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  reportType=${Report_Types[2]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
        Set Suite Variable  ${ReportId2_c8}      ${resp.json()['reportRequestId']}
        Should Be Equal As Strings  Date Range       ${resp.json()['reportContent']['reportHeader']['Time Period']}
        Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
        Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['from']}
        Should Be Equal As Strings  ${DAY60}               ${resp.json()['reportContent']['to']}
        Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
        Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
        Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
        Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
        Set Suite Variable  ${DonationRef_id201}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
        resetsystem_time




*** Keywords ***
Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${start}   ${length}
            
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

        ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Enable Tax
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${ifsc_code}=   db.Generate_ifsc_code
        ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
        ${bank_name}=  FakerLibrary.company
        ${name}=  FakerLibrary.name
        ${branch}=   db.get_place
        ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME${a}}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  payuVerify  ${acc_id}
        Log  ${resp}
        ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME${a}}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  SetMerchantId  ${acc_id}  ${merchantid}

        ${resp}=  View Waitlist Settings
	Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME${a}}
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   clear_service       ${PUSERNAME${a}}
        Exit For Loop IF     '${check}' == 'True'

    END  



***comment***

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
    
