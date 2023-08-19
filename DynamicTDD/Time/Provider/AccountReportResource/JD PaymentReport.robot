*** Settings ***
Suite Teardown    Run Keywords   Delete All Sessions  resetsystem_time
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
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

***Keywords***

Billable Domain Providers
    [Arguments]  ${min}=0   ${max}=260
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${min}   ${max}    
        ${resp}=  Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  View Waitlist Settings
	    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${pkg_id}=   get_highest_license_pkg
        Log   ${pkg_id}
        Set Suite Variable     ${pkg_id[0]}
        ${resp3}=  Get Business Profile
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${check1}   ${resp3.json()['licensePkgID']}
        Set Suite Variable   ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword If    '${check}' == 'True' and '${check1}' == '${pkg_id[0]}'   Append To List   ${provider_list}   ${PUSERNAME${a}}
    END
    [Return]  ${provider_list}

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
    [Return]  ${subdomain}  ${Status}



*** Test Cases ***

JD-TC-Payment_Report-1
    [Documentation]  Last_Week Payment_Report when consumer doing the prepayment  first then full payment
   
    ${billable_providers}=    Billable Domain Providers   min=10   max=20
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

    ${resp}=  Provider Login  ${billable_providers[4]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${billable_providers[4]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${billable_providers[4]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

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
    # ${sTime}=  add_time  2   00
    # ${eTime}=  add_time   2   15
    ${sTime}=  add_time  0   10
    ${eTime}=  add_time   1   10
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
    ${totalamt2}=  twodigitfloat  ${totalamt}
    Set Test Variable  ${totalamt2}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    # ${balamount1}=  Convert To Number  ${balamount}  2
    ${balamount1}=  twodigitfloat  ${balamount}
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    Set Suite Variable  ${jid_c15}   ${resp.json()['consumer']['jaldeeId']}

    # ${resp}=  Make payment Consumer  ${min_pre1}  ${payment_modes[2]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${pre_float1} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL15} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME15} ></td>

    ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref_pre1}   ${resp.json()['paymentRefId']}
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref_pre1} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[1]}
    # Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}  amountDue=${balamount1}    totalTaxAmount=${tax}
    Set Suite Variable  ${c15_BillId1}      ${resp.json()['billId']}


    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}

    #  ##################################################################################
    ${resp}=   ProviderLogin   ${billable_providers[4]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ReportTime}=  db.get_time
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
   
    ${filter}=  Create Dictionary   providerOwnConsumerId-eq=${jid_c15}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Reciepts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${Pre_amount1}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    Should Be Equal As Strings  ${payref_pre1}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id100}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    
    
    #  ##################################################################################

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Make payment Consumer Mock  ${balamount1}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_balance1}   ${resp.json()['paymentRefId']}
    
    sleep   02s
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${balamount1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref_balance1} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[1]}

    # Should Be Equal As Strings  ${resp.json()[1]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}   ${payref_pre1} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}   ${purpose[0]}


    ${resp}=   ProviderLogin   ${billable_providers[4]}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}
    
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid_c15}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
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

    Should Be Equal As Strings  Payment Reciepts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}

    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['16']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['16']}' == '${payref_balance1}'  # ConfirmationId
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        # ...    AND  Should Be Equal As Strings  ${CustomerName}          ${resp.json()['reportContent']['data'][0]['2']}  # CustomerName
        # ...    AND  Should Be Equal As Strings  ${CustomerName}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][${i}]['5']}  # BookingType
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][${i}]['8']}  # Bill_Id
        ...    AND  Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][${i}]['9']}  # Bill_Amount
        ...    AND  Should Be Equal As Strings  ${balamount1}        ${resp.json()['reportContent']['data'][${i}]['10']}  # Amount_Paid
        # ...    AND  Should Be Equal As Strings  ${Gateway_fees}        ${resp.json()['reportContent']['data'][0]['10']}  # Gateway_fees
        # ...    AND  Should Be Equal As Strings  ${Service_fees_tax}        ${resp.json()['reportContent']['data'][0]['11']}  # Service_fees_tax
        # ...    AND  Should Be Equal As Strings  ${Jaldee_service_fees}        ${resp.json()['reportContent']['data'][0]['12']}  # Jaldee_service_fees
        # ...    AND  Should Be Equal As Strings  ${Net_Amount}        ${resp.json()['reportContent']['data'][0]['13']}  # Net_Amount
        ...    AND  Should Be Equal As Strings  ${payref_balance1}        ${resp.json()['reportContent']['data'][${i}]['16']}  # Payment_Id
        ...    AND  Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][${i}]['11']}  # Mode_of_tansaction
        # ...    AND  Should Be Equal As Strings  ${Bank}        ${resp.json()['reportContent']['data'][0]['16']}  # Bank
        ...    AND  Set Suite Variable  ${BillRef_id102}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId
        ...    AND  Should Be Equal As Strings  ${BillRef_id100}   ${BillRef_id102}

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['16']}' == '${payref_pre1}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][${i}]['5']}  # BookingType
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][${i}]['8']}  # Bill_Id
        ...    AND  Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][${i}]['9']}  # Bill_Amount
        ...    AND  Should Be Equal As Strings  ${Pre_amount1}        ${resp.json()['reportContent']['data'][${i}]['10']}  # Amount_Paid
        ...    AND  Should Be Equal As Strings  ${payref_pre1}        ${resp.json()['reportContent']['data'][${i}]['16']}  # Payment_Id
        ...    AND  Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][${i}]['11']}  # Mode_of_tansaction
        ...    AND  Set Suite Variable  ${BillRef_id101}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId
        ...    AND  Should Be Equal As Strings  ${BillRef_id101}   ${BillRef_id100}
    END


    ${LAST_WEEK_DAY1}=  get_date
    Set Suite Variable  ${LAST_WEEK_DAY1} 
    ${LAST_WEEK_DAY7}=  add_date  6
    Set Suite Variable  ${LAST_WEEK_DAY7}

    change_system_date   7


    ${resp}=   ProviderLogin   ${billable_providers[4]}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      LAST_WEEK
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid_c15}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c15}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Reciepts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${LAST_WEEK_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK_DAY7}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}

    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['16']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['16']}' == '${payref_balance1}'  # ConfirmationId
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][${i}]['5']}  # BookingType
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][${i}]['8']}  # Bill_Id
        ...    AND  Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][${i}]['9']}  # Bill_Amount
        ...    AND  Should Be Equal As Strings  ${balamount1}        ${resp.json()['reportContent']['data'][${i}]['10']}  # Amount_Paid
        ...    AND  Should Be Equal As Strings  ${payref_balance1}        ${resp.json()['reportContent']['data'][${i}]['16']}  # Payment_Id
        ...    AND  Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][${i}]['11']}  # Mode_of_tansaction
        ...    AND  Set Suite Variable  ${BillRef_id102}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId
        ...    AND  Should Be Equal As Strings  ${BillRef_id100}   ${BillRef_id102}

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['16']}' == '${payref_pre1}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][${i}]['5']}  # BookingType
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][${i}]['8']}  # Bill_Id
        ...    AND  Should Be Equal As Strings  ${totalamt2}        ${resp.json()['reportContent']['data'][${i}]['9']}  # Bill_Amount
        ...    AND  Should Be Equal As Strings  ${Pre_amount1}        ${resp.json()['reportContent']['data'][${i}]['10']}  # Amount_Paid
        ...    AND  Should Be Equal As Strings  ${payref_pre1}        ${resp.json()['reportContent']['data'][${i}]['16']}  # Payment_Id
        ...    AND  Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][${i}]['11']}  # Mode_of_tansaction
        ...    AND  Set Suite Variable  ${BillRef_id101}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId
        ...    AND  Should Be Equal As Strings  ${BillRef_id101}   ${BillRef_id100}

    END
    resetsystem_time
    

JD-TC-Payment_Report-2
    [Documentation]  Last_Week Payment_Report while checkin more than one person and completing prepayment
    resetsystem_time
    ${PUSERPH3}=  Evaluate  ${PUSERNAME}+8244204
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH3}${\n}
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
    Should Be Equal As Strings    ${resp.json()}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH3}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERPH3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  db.get_time
    ${eTime}=  add_time   1  00
    # ${eTime}=  add_time   0  30
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
    
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH3}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid1}=  get_acc_id  ${PUSERPH3}
    Set Suite Variable  ${pid1}
    ${resp}=  payuVerify  ${pid1}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH3}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}

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
    # ${sTime}=  add_time  2   00
    # ${eTime}=  add_time   2   15
    ${sTime}=  add_time  0   10
    ${eTime}=  add_time   0   50
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


    # ${resp}=  Make payment Consumer  ${amount}  ${payment_modes[2]}  ${cwid}  ${pid1}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${amt_float} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL4} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME4} ></td>

    ${resp}=  Make payment Consumer Mock  ${amount}  ${bool[1]}  ${cwid}  ${pid1}  ${purpose[0]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_pre2}   ${resp.json()['paymentRefId']}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c4_BillId2}      ${resp.json()['billId']}

    sleep  02s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    Set Suite Variable  ${jid_c04}   ${resp.json()['consumer']['jaldeeId']}
    
    

    ${resp}=   ProviderLogin  ${PUSERPH3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ReportTime}=  db.get_time
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid_c04}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c4}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Reciepts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c4_BillId2}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${Total_amt2}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
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

    ${resp}=  Make payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}  ${pid1}  ${purpose[1]}  ${cid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref_balance2}   ${resp.json()['paymentRefId']}
    sleep   01s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}


    ${resp}=   ProviderLogin  ${PUSERPH3}  ${PASSWORD} 
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
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid_c04}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c4}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Reciepts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c4_BillId2}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${Total_amt2}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${Balance}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    Should Be Equal As Strings  ${payref_balance2}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id202}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    


JD-TC-Payment_Report-3
    [Documentation]  Last_Week Payment_Report when prepay full amount 
   
    clear_location  ${billable_providers[4]}
    clear_service    ${billable_providers[4]}
    clear_queue     ${billable_providers[4]}
    ${pid}=  get_acc_id  ${billable_providers[4]}
    Set Suite Variable  ${pid}

    ${resp}=  Provider Login  ${billable_providers[4]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${billable_providers[4]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${billable_providers[4]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

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
    # ${sTime}=  add_time  2   00
    # ${eTime}=  add_time   2   15
    ${sTime}=  add_time  0   10
    ${eTime}=  add_time   0   55

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

    # ${resp}=  Make payment Consumer  ${totalamt}  ${payment_modes[2]}  ${cwid3}  ${pid}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${totalamt3} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL16} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME16} ></td>

    ${resp}=  Make payment Consumer Mock  ${totalamt}  ${bool[1]}  ${cwid3}  ${pid}  ${purpose[0]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
 
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
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}    waitlistStatus=${wl_status[0]}

    ${resp}=   ProviderLogin  ${billable_providers[4]}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Waitlist By Id  ${cwid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${ReportTime}=  db.get_time
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    ${filter2}=  Create Dictionary   providerOwnConsumerId-eq=${jid_c16}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c16}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Payment Reciepts         ${resp.json()['reportContent']['reportName']}
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
    



