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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***

@{emptylist} 
${self}         0
${CUSERPH}      ${CUSERNAME}

***Test Cases***


JD-TC-GenerateReimburseReportforUser-1
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by multi user(account level) then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then reimburse partial amount to the provider.

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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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


JD-TC-GenerateReimburseReportforUser-2
    
    [Documentation]   take a walkin checkin(today, without prepayment, for physical service) by multi user(user level) then 
    ...   do the bill payment through jaldee bank, then verify the reimburse report by SA.
    ...   then reimburse partial amount to the provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME111}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=  FakerLibrary.sentence
    ${P1SERVICE1}=    FakerLibrary.word
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${servicecharge}=  FakerLibrary.Random Int  min=200  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service For User  ${P1SERVICE1}  ${desc}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
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

    ${resp}=  Create Queue For User    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${locId}  ${u_id}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${pcid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid1} 
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

