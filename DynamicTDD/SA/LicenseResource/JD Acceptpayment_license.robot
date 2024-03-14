*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Payment
Library           Collections
Library           String
Library           json
Library           FakerLibrary  
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***

@{acceptPaymentBy}   cash  other

${empty}   0
${tz}   Asia/Kolkata

***Test Cases***

JD-SA-TC-Accept Payments-1
    
    [Documentation]   Superadmin Acceptpayment  in fullpaidamount
	#${amountToPay}   24
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text
	Set Test Variable  ${collectedDate}
	${id}=  get_acc_id  ${PUSERNAME67} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200

    
	${resp}=  AcceptPayment By Superadmin     ${uid}  ${acceptBy}  ${cltdby}  ${collectedDate}  ${note}    ${amountToPay}
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   Paid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   Paid
	#Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}    ${amountToPay}
	
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	Should Be Equal As Strings  ${resp.status_code}  200






JD-SA-TC-Accept Payments-2
    
    [Documentation]  Superadmin Acceptpayment on Statement  in 0 payment
	#${amountToPay}=   12
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	Set Test Variable  ${collectedDate}
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${id}=  get_acc_id  ${PUSERNAME106} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200
   # ${partially}=     Evaluate   ${amountToPay}/2
    
	${resp}=  AcceptPayment By Superadmin     ${uid}  ${acceptBy}  ${cltdby}  ${collectedDate}  ${note}    0  
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}  Paid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
#	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   PartiallyPaid
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id} 
#	Should Be Equal As Strings   ${resp.json()[0]['PaymentDetails'][0]['paymentAmount']}    ${partially}
	Should Be Equal As Strings  ${resp.status_code}  200




JD-SA-TC-Accept Payments-3
    
    [Documentation]  Superadmin Acceptpayment on Statement  in PartiallyPaid
	#${amountToPay}=   12
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	Set Test Variable  ${collectedDate}
	${id}=  get_acc_id  ${PUSERNAME77} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200
    #${20per}=     Evaluate   ${amountToPay}*0.2
	#${grea}=     Evaluate   ${20per}>${amountToPay}*0.2
    
	${resp}=  AcceptPayment By Superadmin   ${uid}  ${acceptBy}  ${cltdby}  ${collectedDate}  ${note}    2
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   PartiallyPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   PartiallyPaid
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id} 
	Should Be Equal As Strings   ${resp.json()[0]['PaymentDetails'][0]['paymentAmount']}    2.0
	Should Be Equal As Strings  ${resp.status_code}  200







#JD-SA-TC-Accept Payments -UH1	
 #   [Documentation]    Superadmin Acceptpayment on Statement -Empty uuid
#	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#	Should Be Equal As Strings  ${resp.status_code}  200
#	${id}=  get_acc_id  ${PUSERNAME67}
#	${collectedDate}=  db.add_timezone_date  ${tz}  -2
#	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
#	${resp}=  Get Invoices superadmin  ${id}  NotPaid
#	Log  ${resp.content}
#	${resp}=   


#    ${Empty}   ${acceptBy}  ${cltdby}   ${collectedDate}  ${note}   2
#	Log  ${resp.content}
#	Should Be Equal As Strings    ${resp.status_code}    422
#	Should Be Equal As Strings  ${resp.content}  "${NO_INVOICE_FOR_UUID}"




JD-SA-TC-Accept Payments -UH1	
    [Documentation]    Superadmin Acceptpayment on Statement - invalied uuid
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${id}=  get_acc_id  ${PUSERNAME67}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
	${resp}=  Get Invoices superadmin  ${id}  NotPaid
	Log  ${resp.content}
	${resp}=   AcceptPayment By Superadmin    0    ${acceptBy}  ${cltdby}   ${collectedDate}  ${note}   2
	Log  ${resp.content}
	Should Be Equal As Strings    ${resp.status_code}    422
	Should Be Equal As Strings  ${resp.content}  "${NO_INVOICE_FOR_UUID}"








JD-SA-TC-Accept Payments -4
    [Documentation]  Superadmin AcceptPayment On Statement -but CollectedBy is Empty
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${id}=  get_acc_id   ${PUSERNAME25}
	${cancelReason}=     FakerLibrary.name
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id1}      ${resp.json()[0]['addons'][2]['addonId']}
	Set Suite Variable    ${addon_name1}      ${resp.json()[0]['addons'][2]['addonName']}
    Log   ${addon_id1}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id1}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id1} 
	should be equal as strings  ${resp.json()[0]['name']}  ${addon_name1}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}  NotPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
    #sleep  06s
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
	Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}


    ${resp}=   AcceptPayment By Superadmin     ${uid}    ${acceptBy}     ${Empty}     ${collectedDate}   ${note}    1
	Should Be Equal As Strings  ${resp.status_code}  200
	Log   ${resp.content}
#	Should Be Equal As Strings  ${resp.content}   "${COLLECTED_BY}"
    ${resp}=  Get Invoices superadmin  ${id}   PartiallyPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   PartiallyPaid
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id} 
	Should Be Equal As Strings   ${resp.json()[0]['PaymentDetails'][0]['paymentAmount']}    1.0
	Should Be Equal As Strings  ${resp.status_code}  200





JD-SA-TC-Accept Payments -UH2
    [Documentation]  Superadmin AcceptPayment On Statement -greater ammount
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${id}=  get_acc_id   ${PUSERNAME67}
	${cancelReason}=     FakerLibrary.name
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id1}      ${resp.json()[0]['addons'][2]['addonId']}
	Set Suite Variable    ${addon_name1}      ${resp.json()[0]['addons'][2]['addonName']}
    Log   ${addon_id1}
	Should Be Equal As Strings  ${resp.status_code}  200
	
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	#should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id1} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name1}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}  NotPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
    sleep  06s
	#Set Suite Variable   ${yuid}   ${resp.json()[0]['ynwUuid']} 
	#Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	#Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}


    ${resp}=   AcceptPayment By Superadmin     ${uid}   ${acceptBy}  ${Empty}   ${collectedDate}  ${note}    100000
	Should Be Equal As Strings  ${resp.status_code}  422
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.content}   "${Payment_is_not_possible}"
#	Should Be Equal As Strings  ${resp.content}   "${COLLECTED_BY}"
#	Should Be Equal As Strings  ${resp.content}   "${Payment_is_not_possible}"





JD-SA-TC-Accept Payments -UH3
    [Documentation]   Acceptpayment on invoice With ConsumerLogin
    ${resp} =   Consumer Login  ${CUSERNAME}  ${PASSWORD}
 	${id} =  get_acc_id   ${CUSERNAME1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cancelReason}=     FakerLibrary.name
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    ${resp}=  AcceptPayment By Superadmin     ${uid}   ${acceptBy}  ${cltdby}   ${collectedDate}  ${note}    3
	Should Be Equal As Strings  ${resp.content}   "Session expired"
	Should Be Equal As Strings  ${resp.status_code}  419



JD-SA-TC-Accept Payments -UH4
  [Documentation]   Acceptpayment on invoice with Providerlogin
	${resp} =  Encrypted Provider Login    ${PUSERNAME}  ${PASSWORD}
	${id}=  get_acc_id   ${PUSERNAME2}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${cancelReason}=     FakerLibrary.name
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    ${resp}=  AcceptPayment By Superadmin     ${uid}   ${acceptBy}  ${cltdby}    ${collectedDate}   ${note}    2
	Should Be Equal As Strings  ${resp.content}   "Session expired"
	Should Be Equal As Strings  ${resp.status_code}  419







JD-SA-TC-Accept Payments -5
    [Documentation]  Superadmin AcceptPayment On Statement -Empty note
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	Set Test Variable  ${collectedDate}
	${id}=  get_acc_id  ${PUSERNAME32} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200

    
	${resp}=  AcceptPayment By Superadmin     ${uid}    ${acceptBy}    ${cltdby}    ${collectedDate}   ${Empty}     2.0
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
  #   Should Be Equal As Strings  ${resp.content}   "Collected date should not be null"
    ${resp}=  Get Invoices superadmin  ${id}   PartiallyPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   PartiallyPaid
	Should Be Equal As Strings   ${resp.json()[0]['PaymentDetails'][0]['paymentAmount']}    2.0
	Should Be Equal As Strings  ${resp.status_code}  200








JD-SA-TC-Accept Payments -UH5
    [Documentation]  Superadmin AcceptPayment On Statement -but it's a Cancelled Statement
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	Set Test Variable  ${collectedDate}
	${cancelReason}=     FakerLibrary.name
	${id}=  get_acc_id  ${PUSERNAME122} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200

    
	
    sleep  06s
	${resp}=  Cancel Invoice    ${uid}    ${cancelReason}
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  AcceptPayment By Superadmin     ${uid}   ${acceptBy}  ${cltdby}   ${collectedDate}  ${note}   2
	Should Be Equal As Strings    ${resp.status_code}    422
	Should Be Equal As Strings  ${resp.content}   "${CAN_NOT_DO_THIS_ON_CANCELLED_INVOICE}"



JD-SA-TC-Accept Payments -UH6
    [Documentation]  Superadmin AcceptPayment On Statement -but CollectedDate is Empty
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	Set Test Variable  ${collectedDate}
	${id}=  get_acc_id  ${PUSERNAME47} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200

    
	${resp}=  AcceptPayment By Superadmin     ${uid}  ${acceptBy}  ${cltdby}  ${Empty}  ${note}    ${amountToPay}
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.content}   "Collected date should not be null"





	


JD-SA-TC-Accept Payments -UH7
    [Documentation]  Superadmin AcceptPayment On Statement -but CollectedDate is Future date
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${F_collectedDate}=  db.add_timezone_date  ${tz}  2  
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	Set Test Variable  ${F_collectedDate}
	${id}=  get_acc_id  ${PUSERNAME59} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200

    
	${resp}=  AcceptPayment By Superadmin     ${uid}  ${acceptBy}  ${cltdby}  ${F_collectedDate}  ${note}    ${amountToPay}
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.content}   "${NOT_ACCEPT_FUTUREDATE}"




JD-SA-TC-Accept Payments-6
    
    [Documentation]  Superadmin Acceptpayment on Statement  in 0.1 payment(less than)
	#${amountToPay}=   12
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	Set Test Variable  ${collectedDate}
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${id}=  get_acc_id  ${PUSERNAME116} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200
   # ${partially}=     Evaluate   ${amountToPay}/2
    
	${resp}=  AcceptPayment By Superadmin     ${uid}  ${acceptBy}  ${cltdby}  ${collectedDate}  ${note}    0.1 
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}  PartiallyPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
#	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   PartiallyPaid
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id} 
	Should Be Equal As Strings   ${resp.json()[0]['PaymentDetails'][0]['paymentAmount']}    0.1
	Should Be Equal As Strings  ${resp.status_code}  200



	
	

*** Comments ***
JD-SA-TC-Accept Payments-7
    
    [Documentation]  Superadmin Acceptpayment on Statement  invalied mesg passed payment 
	#${amountToPay}=   12
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${DAY1}=  db.get_date_by_timezone  ${tz}
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
    Set Suite Variable  ${createdDate}  ${DAY1}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	Set Test Variable  ${collectedDate}
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${id}=  get_acc_id  ${PUSERNAME156} 
	${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
    Log   ${addon_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Add Addons details  ${id}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	#should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}   NotPaid
	Log  ${resp.content}
	Set Suite Variable   ${uid}  ${resp.json()[0]['ynwUuid']} 
    Set Suite Variable   ${amountToPay}   ${resp.json()[0]['amountToPay']} 
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
    Should Be Equal As Strings  ${resp.json()[0]['periodFrom']}   ${createdDate}
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id}  
	#Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addonName']}  ${addon_name}	
	Should Be Equal As Strings  ${resp.json()[0]['debit']}    0.0
	Should Be Equal As Strings  ${resp.json()[0]['credit']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['amountToPay']}   ${amountToPay}
    Should Be Equal As Strings    ${resp.status_code}    200
   # ${partially}=     Evaluate   ${amountToPay}/2
    
	${resp}=  AcceptPayment By Superadmin     ${uid}  ${acceptBy}  ${cltdby}  ${collectedDate}  ${note}    dgfb
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Invoices superadmin  ${id}  PartiallyPaid
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${id}
	Should Be Equal As Strings  ${resp.json()[0]['createdDate']}  ${createdDate} 
#	Should Be Equal As Strings  ${resp.json()[0]['licensePaymentStatus']}   PartiallyPaid
	Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${addon_id} 
	Should Be Equal As Strings   ${resp.json()[0]['PaymentDetails'][0]['paymentAmount']}    0.1
	Should Be Equal As Strings  ${resp.status_code}  200
	JD-SA-TC-Accept Payments -UH5
    [Documentation]  Superadmin AcceptPayment On Statement -but Invoice is already Paid
	${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200
	${id}=  get_acc_id   ${PUSERNAME67}
	${collectedDate}=  db.add_timezone_date  ${tz}  -2
	${cltdby}=   FakerLibrary.name
    ${note}=     FakerLibrary.text

	${cancelReason}=     FakerLibrary.name
	${acceptBy}=  evaluate  random.choice($acceptPaymentBy)  random
	${resp}=  Get Invoices superadmin  ${id}  Paid
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  AcceptPayment By Superadmin         ${uid}   ${acceptBy}  ${cltdby}   ${collectedDate}  FGHGHHJ    2
	Should Be Equal As Strings  ${resp.status_code}  422
	Log   ${resp.content}	
	Should Be Equal As Strings  ${resp.content}   "Invoice already paid"




	
	


		