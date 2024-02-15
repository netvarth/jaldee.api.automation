*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Payment Report
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
@{multiples}  10  20  30   40   50

***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Log  ${resp.json()}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${Status}=   Run Keyword And Return Status   Run Keywords   Should Be True   '${resp.json()['maxPartySize']}' > '${1}'  AND   Should Be True  '${resp.json()['serviceBillable']}' == '${bool[1]}'
            Exit For Loop IF  ${Status}
    END
    RETURN  ${subdomain}  ${Status}



*** Test Cases ***

JD-TC-Payment_Report-1
    [Documentation]  Payment_Report when consumer doing the prepayment  first then full payment
   
    ${billable_providers}=    Billable Domain Providers   min=240   max=250
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    clear_location  ${billable_providers[4]}
    clear_service    ${billable_providers[4]}
    clear_queue     ${billable_providers[4]}
    clear_customer   ${billable_providers[4]}

    ${pid}=  get_acc_id  ${billable_providers[4]}
    Set Suite Variable  ${pid}

    ${resp}=  Encrypted Provider Login  ${billable_providers[4]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Location By Id  ${p1_lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()['id']} 
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  add_timezone_time  ${tz}  2  00  
    # ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${sTime}=  add_timezone_time  ${tz}  0   10
    ${eTime}=  add_timezone_time  ${tz}   1   10
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()['id']}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    ${pre_amount1}=  twodigitfloat  ${min_pre1}
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt1}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount1}=  twodigitfloat  ${balamount}  
    ${bal_amt1}=  Convert To twodigitfloat  ${balamount}
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    Set Suite Variable  ${jid_c15}   ${resp.json()['consumer']['jaldeeId']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref_pre1}   ${resp.json()['paymentRefId']}
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref_pre1} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}  amountDue=${balamount1}    totalTaxAmount=${tax}
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[1]}
    Set Suite Variable  ${c15_BillId1}      ${resp.json()['billId']}


    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}



    #  ##################################################################################
    ${resp}=   Encrypted Provider Login   ${billable_providers[4]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${jid1_c15}=  Convert To String  ${jid_c15} 
    # ${filter}=  Create Dictionary   providerOwnConsumerId-eq=${jid1_c15}  
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Receipts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt1}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${Pre_amount1}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    # Should Be Equal As Strings  ${payref_pre1}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id100}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
    
    #  ##################################################################################

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${bal_amt1}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_balance1}   ${resp.json()['paymentRefId']}
    
    sleep   02s
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${bal_amt1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref_balance1} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[1]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}   ${payref_pre1} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}   ${purpose[0]}


    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[1]}
   

    ${resp}=   Encrypted Provider Login   ${billable_providers[4]}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}
    
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${jid1_c15}=  Convert To String  ${jid_c15} 
    # ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid1_c15}  
    ${filter2}=  Create Dictionary  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s

    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c15}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${cust_id}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}

    # Should Be Equal As Strings  ${Gateway_Fee}       ${resp.json()['reportContent']['dataHeader']['Total Gateway Fee']}
    # Should Be Equal As Strings  ${JService_Fee}       ${resp.json()['reportContent']['dataHeader']['Total Jaldee Service Fee']}
    # Should Be Equal As Strings  ${Settle_Amt}       ${resp.json()['reportContent']['dataHeader']['Total Settlement Amount']}
    # Should Be Equal As Strings  ${NetTotal}       ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    Should Be Equal As Strings  Payment Receipts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    # Should Be Equal As Strings  ${CustomerName}          ${resp.json()['reportContent']['data'][0]['2']}  # CustomerName
    # Should Be Equal As Strings  ${CustomerName}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt1}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${balamount1}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    # Should Be Equal As Strings  ${Gateway_fees}        ${resp.json()['reportContent']['data'][0]['10']}  # Gateway_fees
    # Should Be Equal As Strings  ${Service_fees_tax}        ${resp.json()['reportContent']['data'][0]['11']}  # Service_fees_tax
    # Should Be Equal As Strings  ${Jaldee_service_fees}        ${resp.json()['reportContent']['data'][0]['12']}  # Jaldee_service_fees
    # Should Be Equal As Strings  ${Net_Amount}        ${resp.json()['reportContent']['data'][0]['13']}  # Net_Amount
    # Should Be Equal As Strings  ${payref_balance1}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    # Should Be Equal As Strings  ${Bank}        ${resp.json()['reportContent']['data'][0]['16']}  # Bank
    Set Suite Variable  ${BillRef_id102}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    Should Be Equal As Strings  ${BillRef_id100}   ${BillRef_id102}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][1]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][1]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt1}        ${resp.json()['reportContent']['data'][1]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${Pre_amount1}        ${resp.json()['reportContent']['data'][1]['10']}  # Amount_Paid
    # Should Be Equal As Strings  ${payref_pre1}        ${resp.json()['reportContent']['data'][1]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][1]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id101}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    Should Be Equal As Strings  ${BillRef_id101}   ${BillRef_id100}
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['23']}   ${DAY}        
    Should Be Equal As Strings   ${resp.json()['reportContent']['reportGeneratedOn']}   ${Date_Time}      
    Should Be Equal As Strings   ${resp.json()['reportContent']['date']}   ${DAY}     

JD-TC-Payment_Report-UH1
    [Documentation]  Generate Payment_Report without login
    
    ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory2}      LAST_WEEK

    ${filter}=  Create Dictionary   providerOwnConsumerId-eq=${pcid23}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

    
JD-TC-Payment_Report-UH2
    [Documentation]  Generate Payment_Report using Consumer_login
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid23}=  get_id  ${CUSERNAME23}

    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   providerOwnConsumerId-eq=${pcid23}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

    
JD-TC-Payment_Report-UH3
    [Documentation]  Generate Payment_Report using provider_own_consumerId as EMPTY
    ${resp}=   Encrypted Provider Login   ${billable_providers[4]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory1}      NEXT_WEEK
    ${filter}=  Create Dictionary   providerOwnConsumerId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   providerOwnConsumerId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Payment_Report-2

    [Documentation]   Generate payment report for donation,

    ${billable_providers}=    Billable Domain Providers   min=240   max=250
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    clear_location  ${billable_providers[3]}
    clear_service    ${billable_providers[3]}
    clear_queue     ${billable_providers[3]}
    clear_customer   ${billable_providers[3]}

    ${acc_id}=  get_acc_id  ${billable_providers[3]}
    Set Test Variable  ${acc_id}

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp} 

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE1}=    FakerLibrary.word
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
    Set Test Variable  ${sid1}  ${resp.json()}

    ${resp}=   Consumer Login  ${CUSERNAME22}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${d_fname}=    FakerLibrary.word
    ${d_lname}=    FakerLibrary.word
    Set Test Variable   ${Donor_name}    ${d_fname} ${d_lname}
    ${con_id}=  get_id  ${CUSERNAME22}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}
    ${don_amt_float}=  twodigitfloat  ${don_amt}
    ${Donation_amt}=  commaformatNumber  ${don_amt}

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
    
    ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[0]}  ${con_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Current_Date} =	Convert Date	${CUR_DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Current_Date}

    Set Test Variable  ${paymentPurpose-eq2}      donation
    # Set Test Variable  ${reportType}              DONATION
    Set Test Variable  ${reportDateCategory}      TODAY
    # ${don_amt11}=  Convert To String  ${don_amt} 
    ${filter2}=  Create Dictionary   
    ${resp}=  Generate Report REST details  ${reportType[3]}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    # sleep  04s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId1_c8}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Donation Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  ${token_id}                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${CUR_DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${d_fname}               ${resp.json()['reportContent']['data'][0]['2']}  # Customer Name (Donor)
    Should Be Equal As Strings  ${SERVICE1}        ${resp.json()['reportContent']['data'][0]['4']}  # Service
    Should Be Equal As Strings  ${Donation_amt}      ${resp.json()['reportContent']['data'][0]['6']}  # Donation_Amount 
    Set Suite Variable  ${DonationRef_id101}     ${resp.json()['reportContent']['data'][0]['5']}  # ConfirmationId
    

*** comment ***


JD-TC-Payment_Report-2
    [Documentation]  Payment_Report while checkin more than one person and completing prepayment

    ${PUSERPH3}=  Evaluate  ${PUSERNAME}+8244204
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH3}${\n}
    Set Suite Variable   ${PUSERPH3}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH3}  AND  clear_service  ${PUSERPH3}  AND  clear_location  ${PUSERPH3}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH3}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH3}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    true
    
    ${resp}=  Account Set Credential  ${PUSERPH3}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid1}=  get_acc_id  ${PUSERPH3}
    Set Suite Variable  ${pid1}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    # ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}
    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
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

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_lid}  ${resp.json()[0]['id']} 

    ${prepay}=   Random Int   min=49   max=50
    ${Tot}=   Random Int   min=499   max=500
    ${prepay1}=  Convert To Number  ${prepay}  1
    Set Suite Variable   ${prepay}   ${prepay1}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Test Variable   ${Tot}   ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${prepay}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  add_timezone_time  ${tz}  2  00  
    # ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${sTime}=  add_timezone_time  ${tz}  0   10
    ${eTime}=  add_timezone_time  ${tz}   0   50
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p4_lid}  ${p4_sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid11}  ${resp.json()['id']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cid1for}   ${resp.json()}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p4_qid}  ${DAY}  ${p4_sid1}  ${msg}  ${bool[0]}  ${cid1for}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    Set Test Variable  ${cwidfam}  ${wid[1]} 

    ${totcharge}=  Evaluate  ${Tot}*2
    ${tax1}=  Evaluate  ${totcharge}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=   Evaluate  ${totcharge}+${tax}
    ${totalamt2}=  twodigitfloat  ${totalamt}
    ${amount_paid}=   Evaluate  ${prepay}*2
    ${amount}=  Convert To Number  ${amount_paid}  1
    ${amt_float}=  twodigitfloat  ${amount}
    ${balamount}=  Evaluate  (${totcharge}+${tax})-${amount}
    ${balamount2}=  twodigitfloat  ${balamount}
    ${Total_amt2}=  commaformatNumber  ${totalamt}
    ${amount_paid2}=  commaformatNumber  ${amount_paid}
    ${Balance}=  commaformatNumber  ${balamount}
    
    ${resp}=  Make payment Consumer Mock  ${pid1}  ${amount}  ${purpose[0]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_pre2}   ${resp.json()['paymentRefId']}

    ${resp}=   Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${cwid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c4_BillId2}      ${resp.json()['billId']}

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}

    sleep  02s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    Set Suite Variable  ${jid_c04}   ${resp.json()['consumer']['jaldeeId']}
    
    

    ${resp}=   Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${jid1_c04}=  Convert To String  ${jid_c04} 
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid1_c04}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c4}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Receipts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c4_BillId2}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${amount_paid2}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    Should Be Equal As Strings  ${payref_pre2}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id202}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid1}  ${balamount}  ${purpose[1]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_balance2}   ${resp.json()['paymentRefId']}
    sleep   01s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}


    ${resp}=   Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Get Waitlist By Id  ${cwidfam}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}
    
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${jid1_c04}=  Convert To String  ${jid_c04}
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid1_c04}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c4}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Receipts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c4_BillId2}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${Balance}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    Should Be Equal As Strings  ${payref_balance2}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id202}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    


JD-TC-Payment_Report-3
    [Documentation]  Payment_Report when prepay full amount 
   
    clear_location  ${billable_providers[4]}
    clear_service    ${billable_providers[4]}
    clear_queue     ${billable_providers[4]}
    ${pid}=  get_acc_id  ${billable_providers[4]}
    Set Suite Variable  ${pid}

    ${resp}=  Encrypted Provider Login  ${billable_providers[4]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  AddCustomer  ${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_lid}  ${resp.json()[0]['id']} 

    ${min_pre}=   Random Int   min=49   max=50
    ${Tot}=   Random Int   min=499   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${pre_float}=  twodigitfloat  ${min_pre}
    Set Suite Variable   ${pre_float}  
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot}   ${Tot1}
    ${Tot_float}=  twodigitfloat  ${Tot}
    Set Suite Variable   ${Tot_float}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable    ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2} 
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid3}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  add_timezone_time  ${tz}  2  00  
    # ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${sTime}=  add_timezone_time  ${tz}  0   10
    ${eTime}=  add_timezone_time  ${tz}   0   55

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p2_lid}  ${p2_sid1}  ${p2_sid2}  ${p2_sid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid12}  ${resp.json()['id']}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p2_qid}  ${DAY}  ${p2_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid3}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    # ${amt_float}=  twodigitfloat  ${totalamt}
    ${totalamt3}=  twodigitfloat  ${totalamt}

    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    Set Suite Variable  ${jid_c16}   ${resp.json()['consumer']['jaldeeId']}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${totalamt}  ${purpose[0]}  ${cwid3}  ${p2_sid1}  ${bool[0]}   ${bool[1]}  ${cid12}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
 
    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    sleep   02s

    ${resp}=   Get Payment Details By UUId   ${cwid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${totalamt}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid3}

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${totalamt}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid3}

    ${resp}=  Get Bill By consumer  ${cwid3}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid3}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  taxableTotal=${Tot}  totalTaxAmount=${tax}
    Set Suite Variable  ${c16_BillId3}      ${resp.json()['billId']}

    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}    waitlistStatus=${wl_status[0]}

    ${resp}=   Encrypted Provider Login  ${billable_providers[4]}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Waitlist By Id  ${cwid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${jid1_c16}=  Convert To String  ${jid_c16}
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid1_c16}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c16}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Receipts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c16_BillId3}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt3}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${totalamt3}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    Should Be Equal As Strings  ${payref}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id302}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    




