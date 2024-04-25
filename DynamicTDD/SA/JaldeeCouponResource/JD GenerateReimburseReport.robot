*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions 
Force Tags        Reimburse Report
Library           Collections
Library           String
Library           json
Library           FakerLibrary  
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

@{emptylist} 
${self}         0
${CUSERPH}      ${CUSERNAME}

***Test Cases***


JD-TC-GenerateReimburseReport-1
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pcid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}    ${ser_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}      ${que_id1} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]} 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}    ${paymentStatus[0]} 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${servicecharge}  ${purpose[1]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-2
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA, 
    ...   then reimburse partial amount to the provider.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pcid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}    ${ser_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}      ${que_id1} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]} 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}    ${paymentStatus[0]} 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${servicecharge}  ${purpose[1]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${servicecharge}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${servicecharge}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-GenerateReimburseReport-3
    
    [Documentation]   take a walkin checkin(today, with prepayment, for physical service) by a provider then 
    ...   do the prepayment and bill payment through jaldee bank, then verify the reimburse report by SA, 
    ...   then reimburse full amount to the provider.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${prepay}=   Random Int  min=1  max=100
    ${prepay}=  Convert To Number  ${prepay}  1
    Set Suite Variable   ${prepay}
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    Set Suite Variable   ${servicecharge}
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${prepay}  ${servicecharge}  ${bool[1]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}         ${bool[1]} 
    Should Be Equal As Numbers  ${resp.json()['minPrePaymentAmount']}  ${prepay} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}          ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}          ${service_type[2]} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pcid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}    ${ser_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}      ${que_id1} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]} 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}    ${paymentStatus[0]} 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${prepay}  ${purpose[0]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[1]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${prepay} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${prepay} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${prepay} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${prepay} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${prepay} 


# ......do the bill payment......

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${amntdue}=  Evaluate   ${servicecharge}-${prepay}
    ${amntdue}=  Convert To Number  ${amntdue}  1
   
    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${amntdue} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${amntdue}  ${purpose[1]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id2}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${amntdue} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${amntdue} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${amntdue} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${amntdue} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${prepay}
    ${invoice2}=  Reimburse Ivoices  ${invoice_id2}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amntdue}
    ${invoices}=  Create List  ${invoice1}   ${invoice2}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${amntdue} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${amntdue} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amntdue} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amntdue}    
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${amntdue} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${amntdue} 

    Should Be Equal As Strings  ${resp.json()[1]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[1]['subTotalJaldeeBank']}                    ${prepay} 
    Should Be Equal As Numbers  ${resp.json()[1]['grantTotal']}                            ${prepay} 
    Should Be Equal As Numbers  ${resp.json()[1]['subJbankTotalPaid']}                     ${prepay} 
    Should Be Equal As Numbers  ${resp.json()[1]['totalPaid']}                             ${prepay}    
    Should Be Equal As Strings  ${resp.json()[1]['status']}                                ${cupnpaymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()[1]['jPaymentDetails']['jBankTotal']}         ${prepay} 
    Should Be Equal As Numbers  ${resp.json()[1]['jPaymentDetails']['settlementAmount']}   ${prepay} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-4
    
    [Documentation]   take an online checkin(today, with prepayment, for physical service) by a provider 
    ...   apply provider coupon then 
    ...   do the payment through jaldee bank, then verify the reimburse report by SA, 
    ...   then reimburse partial amount to the provider.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${ser_id1}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist Consumers  ${account_id1}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${prepay}  ${purpose[0]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amntdue}=  Evaluate   ${servicecharge}-${prepay}
    ${amntdue}=  Convert To Number  ${amntdue}  1

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME122}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid1}  ${cupn_code}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amnttopay}=  Evaluate   ${amntdue}-${pc_amount}
    ${amnttopay}=  Convert To Number  ${amnttopay}  1

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${amnttopay}  ${purpose[1]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${amnttopay} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${amnttopay} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${amnttopay} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${amnttopay} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${amnttopay}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${amnttopay}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}  

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${amnttopay} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${amnttopay} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${amnttopay} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${amnttopay} 


JD-TC-GenerateReimburseReport-5
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then cancel the booking by provider , then check the report.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pcid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}    ${ser_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}      ${que_id1} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]} 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}    ${paymentStatus[0]} 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${servicecharge}  ${purpose[1]}  ${wid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${desc}=   FakerLibrary.word

    ${resp}=  Waitlist Action Cancel  ${wid1}  ${cncl_resn}  ${desc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${report_id}  ${resp.json()[0]['invoiceId']}
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${resp}=  Recreate reimburse report   ${report_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-6
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   do partial payment then cancel the booking by provider , then check the report.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-GenerateReimburseReport-7
    
    [Documentation]   take a walkin appointment(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then cancel the booking by provider , then check the report.
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME125}
    clear_location  ${PUSERNAME125}
    clear_customer   ${PUSERNAME125}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
  
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 
    
    clear_appt_schedule   ${PUSERNAME125}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${servicecharge}  ${purpose[1]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${servicecharge}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${servicecharge}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-8
    
    [Documentation]   take a online appointment(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then do partial payment.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME126}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME126}
    clear_location  ${PUSERNAME126}
    clear_customer   ${PUSERNAME126}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
  
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 
    
    clear_appt_schedule   ${PUSERNAME126}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id1}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME126}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${servicecharge} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${servicecharge}  ${purpose[1]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${servicecharge}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${servicecharge}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${account_id1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${servicecharge} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${servicecharge} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-9
    
    [Documentation]   take a online order(today, without prepayment) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then do partial payment.


    clear_queue    ${PUSERNAME130}
    clear_service  ${PUSERNAME130}
    clear_Item   ${PUSERNAME130}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME130}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME130}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  
    Set Suite Variable  ${itemName1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
   
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+154686
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}${CUSERPH1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}

    Set Suite Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    Set Suite Variable   ${item_quantity1}
    ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity11} 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH1}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id1}  ${resp.json()[0]['id']}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
    ${resp}=  Make payment Consumer Mock  ${accId1}  ${total}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${total} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${accId1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${total} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${total} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${total}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${total}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${accId1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${total} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-10
    
    [Documentation]   take a walkin order(today, without prepayment) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then do partial payment.

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue    ${PUSERNAME131}
    clear_service  ${PUSERNAME131}
    clear_Item   ${PUSERNAME131}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME131}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME131}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  
    Set Suite Variable  ${itemName1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
   
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERNAME20}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME20}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME131}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}   ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
    ${resp}=  Make payment Consumer Mock  ${accId1}  ${total}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid20}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${total} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${accId1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${total} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${total} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${total}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${total}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${accId1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${total} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-11
    
    [Documentation]   take an online order(today, without prepayment,apply jaldee coupon) by a provider then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then do partial payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  ProviderLogout 
    Log    ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${lic2}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    ${cupn_code}=    FakerLibrary.word
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence

    clear_jaldeecoupon  ${cupn_code}

    ${jcpnamnt}=    Random Int   min=10  max=50
    ${jcpnamnt}=  Convert To Number  ${jcpnamnt}  1
    
    ${resp}=  Create Jaldee Coupon  ${cupn_code}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY}  ${DAY2}  ${discountType[0]}  ${jcpnamnt}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${alldomains}  ${allsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode   ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  SuperAdmin Logout 
    Log    ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    clear_queue    ${PUSERNAME132}
    clear_service  ${PUSERNAME132}
    clear_Item   ${PUSERNAME132}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME132}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME132}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  
    Set Suite Variable  ${itemName1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
   
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERNAME12}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERNAME12}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME12}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    Set Suite Variable   ${item_quantity1}
    ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity11} 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH1}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id1}  ${resp.json()[0]['id']}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code    ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalamt}=  Evaluate  ${total} - ${jcpnamnt}
    ${totalamt}=  Convert To Number  ${totalamt}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${totalamt} 

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${totalamt} 
    
    ${resp}=  Make payment Consumer Mock  ${accId1}  ${totalamt}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${totalamt} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id1}   ${resp.json()[0]['invoiceId']}  

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${accId1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${total} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[3]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${total} 

    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
    ${partial_amount}=  Evaluate   ${total}-1
    ${amount_paid}=   Random Int  min=1  max=${partial_amount}
    ${amount_paid}=  Convert To Number  ${amount_paid}  1
    ${amount_due}=   Evaluate   ${total}-${amount_paid}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id1}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${jaldee_reimburse_for[0]}   jbankTotal=${amount_paid}
    ${invoices}=  Create List  ${invoice1}

    ${resp}=  Reimburse Payment  ${invoices}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                            ${accId1} 
    Should Be Equal As Numbers  ${resp.json()[0]['subTotalJaldeeBank']}                    ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['grantTotal']}                            ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['subJbankTotalPaid']}                     ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalPaid']}                             ${amount_paid} 
    Should Be Equal As Numbers  ${resp.json()[0]['jBankBalanceDue']}                       ${amount_due} 
    Should Be Equal As Numbers  ${resp.json()[0]['totalBalanceDue']}                       ${amount_due}     
    Should Be Equal As Strings  ${resp.json()[0]['status']}                                ${cupnpaymentStatus[6]} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}         ${total} 
    Should Be Equal As Numbers  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${total} 

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-12
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment as cash, then verify the reimburse report by SA.
      
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue     ${PUSERNAME56}
    clear_service   ${PUSERNAME56}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pcid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}    ${ser_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}      ${que_id1} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]} 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}    ${paymentStatus[0]} 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  Accept Payment  ${wid1}  ${payment_modes[0]}  ${servicecharge}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain    ${resp.json()}   ${account_id1}

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateReimburseReport-13
    
    [Documentation]   take a walkin appointment(today, without prepayment, for physical service) by a provider then 
    ...   do the bill payment as cash, then verify the reimburse report by SA.
      
    ${resp}=  Encrypted Provider Login  ${PUSERNAME57}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200




    clear_queue     ${PUSERNAME56}
    clear_service   ${PUSERNAME56}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['serviceType']}    ${service_type[2]} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pcid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}    ${ser_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}      ${que_id1} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]} 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}    ${paymentStatus[0]} 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${servicecharge} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${servicecharge} 

    ${resp}=  Accept Payment  ${wid1}  ${payment_modes[0]}  ${servicecharge}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Bill By consumer  ${wid1}  ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${servicecharge} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain    ${resp.json()}   ${account_id1}

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

