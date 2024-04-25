*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Payment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***
JD-TC-Update Account Payment Settings-1
       [Documentation]   update paymentsetting of provider then update the payu verifed as ${bool[1]} then change the value of a field payment setting change  . payuvarifed become ${bool[0]} 
       
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200

*** Comments ***
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       Set Suite Variable  ${firstname}
       ${lastname}=  FakerLibrary.last_name
       ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+510097
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_B}    4
       Log  ${resp.json()}
       #Set Test Variable  ${fname}  ${resp.json()['userProfile']['firstName']}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME_B}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
       Set Suite Variable  ${PUSERNAME_B}
       ${DAY1}=  db.get_date_by_timezone  ${tz}
       Set Suite Variable  ${DAY1}  ${DAY1}
       ${list}=  Create List  1  2  3  4  5  6  7
       Set Suite Variable  ${list}  ${list}
       ${resp}=  Update Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY} 
       Should Be Equal As Strings  ${resp.status_code}  200
       ${acct_id1}=  get_acc_id  ${PUSERNAME_B}
       Set Suite Variable  ${acct_id1}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${businessStatus}=   Random Element   ${businessStatus}  
       Set Suite Variable   ${businessStatus}
       ${accounttype}=      Random Element   ${accounttype} 
       Set Suite Variable   ${accounttype}
       ${resp}=   Update Account Payment Settings  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${PUSERNAME_B}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessStatus}  ${accounttype}   
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response   ${resp}  onlinePayment=${bool[0]}	payTm=${bool[1]}	dcOrCcOrNb=${bool[0]}	payTmLinkedPhoneNumber=${PUSERNAME_B}	panCardNumber=${EMPTY}	bankAccountNumber=${EMPTY}	payUVerified=${bool[1]}	payTmVerified=${bool[0]}	 bankName=${EMPTY} 	ifscCode=${EMPTY}  	nameOnPanCard=${EMPTY}  	accountHolderName=${EMPTY}	branchCity=${EMPTY}            
       ${panCardNumber}=  Generate_pan_number
       Set Suite Variable   ${panCardNumber}
       ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
       Set Suite Variable   ${bankAccountNumber}
       ${bankName}=  FakerLibrary.company
       Set Suite Variable   ${bankName}
       ${ifsc}=  Generate_ifsc_code
       Set Suite Variable   ${ifsc}
       ${panname}=  FakerLibrary.name
       Set Suite Variable   ${panname}
       ${city}=   get_place
       Set Suite Variable   ${city}
       ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}  
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}    
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response  ${resp}  accountId=${acct_id1}  onlinePayment=${bool[1]}  payTm=${bool[0]}  dcOrCcOrNb=${bool[1]}   panCardNumber=${panCardNumber}   bankAccountNumber=${bankAccountNumber}  payUVerified=${bool[1]}  payTmVerified=${bool[0]}  bankName=${bankName}  ifscCode=${ifsc}  nameOnPanCard=${panname}  accountHolderName=${firstname}  branchCity=${city}  businessFilingStatus=${businessStatus}     accountType=${accounttype}

JD-TC-Update Account Payment Settings-2
       [Documentation]   Provider update payment settings for  debitcard or creditcard or Nb

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${acct_id1}=  get_acc_id  ${PUSERNAME_B}
       ${bankAccountNumber1}=  Generate_random_value  size=16  chars=string.digits
       Set Suite Variable   ${bankAccountNumber1}
       ${ifsc1}=  Generate_ifsc_code
       Set Suite Variable   ${ifsc1}
       ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${EMPTY}  ${panCardNumber}  ${bankAccountNumber1}  ${bankName}  ${ifsc1}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response  ${resp}  accountId=${acct_id1}  onlinePayment=${bool[0]}  payTm=${bool[0]}  dcOrCcOrNb=${bool[1]}  payTmLinkedPhoneNumber=${EMPTY}  panCardNumber=${panCardNumber}  bankAccountNumber=${bankAccountNumber1}  payUVerified=${bool[1]}  payTmVerified=${bool[0]}  bankName=${bankName}  ifscCode=${ifsc1}  nameOnPanCard=${panname}  accountHolderName=${firstname}  branchCity=${city}  businessFilingStatus=${businessStatus}     accountType=${accounttype}

JD-TC-Update Account Payment Settings-3
       [Documentation]   Provider try to update payment setting using user dono't have valid email id

       #${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
       #Should Be Equal As Strings    ${resp.status_code}   200

       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       
       ${lastname}=  FakerLibrary.last_name
       ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+510154
       ${email}=  Set Variable  ${P_Email}${PUSERNAME_B}.${test_mail}
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${d1}  ${sd}  ${PUSERNAME_B}    4
       Log  ${resp.json()}
       #Set Test Variable  ${fname}  ${resp.json()['userProfile']['firstName']}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${email}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
       Set Suite Variable  ${PUSERNAME_B}
       ${DAY1}=  db.get_date_by_timezone  ${tz}
       Set Suite Variable  ${DAY1}  ${DAY1}
       ${list}=  Create List  1  2  3  4  5  6  7
       Set Suite Variable  ${list}  ${list}
       ${resp}=  Update Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  
       Should Be Equal As Strings  ${resp.status_code}  200


       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessStatus}   ${accounttype}   
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-Update Account Payment Settings-4
       [Documentation]   provider Update payment settings for Paytm

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${acct_id1}=  get_acc_id  ${PUSERNAME_B}
       ${resp}=   Update Account Payment Settings  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${PUSERNAME_B}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessStatus}   ${accounttype}    
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response  ${resp}  accountId=${acct_id1}  onlinePayment=${bool[0]}  payTm=${bool[1]}  dcOrCcOrNb=${bool[0]}  payTmLinkedPhoneNumber=${PUSERNAME_B}  panCardNumber=${EMPTY}  bankAccountNumber=${EMPTY}  payUVerified=${bool[1]}  payTmVerified=${bool[0]}  bankName=${EMPTY}  ifscCode=${EMPTY}  nameOnPanCard=${EMPTY}  accountHolderName=${EMPTY}  branchCity=${EMPTY}  businessFilingStatus=${businessStatus}     accountType=${accounttype}

       
JD-TC-Update Account Payment Settings-5
       [Documentation]   provider Update payment settings for Paytm  and dehtcard or creditcard NB

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${acct_id1}=  get_acc_id  ${PUSERNAME_B}
       ${bankAccountNumber2}=  Generate_random_value  size=16  chars=string.digits
       Set Suite Variable   ${bankAccountNumber2}
       ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[1]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber2}  ${bankName}  ${ifsc1}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}  
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response  ${resp}  accountId=${acct_id1}  onlinePayment=${bool[0]}  payTm=${bool[1]}  dcOrCcOrNb=${bool[1]}  payTmLinkedPhoneNumber=${PUSERNAME_B}  panCardNumber=${panCardNumber}  bankAccountNumber=${bankAccountNumber2}  payUVerified=${bool[1]}  payTmVerified=${bool[0]}  bankName=${bankName}  ifscCode=${ifsc1}  nameOnPanCard=${panname}  accountHolderName=${firstname}  branchCity=${city}  businessFilingStatus=${businessStatus}     accountType=${accounttype}
  
JD-TC-Update Account Payment Settings-UH1
       [Documentation]   Consumer try to update payment Settings 

       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${fname}  ${resp.json()['firstName']}
       ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[1]}  ${bool[1]}  ${CUSERNAME2}  ${panCardNumber}  ${bankAccountNumber2}  ${bankName}  ${ifsc}  ${panname}  ${fname}  ${city}   ${businessStatus}   ${accounttype}  
       Should Be Equal As Strings  "${resp.json()}"       "${LOGIN_NO_ACCESS_FOR_URL}"
       Should Be Equal As Strings    ${resp.status_code}   401
       
JD-TC-Update Account Payment Settings-UH3
       [Documentation]   upate paymentseting without login

       ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[1]}  ${bool[1]}  ${CUSERNAME2}  ${panCardNumber}  ${bankAccountNumber2}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}  
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
       
JD-TC-Update Account Payment Settings-UH4
       [Documentation]   Provider check to Update payment settins without Pytm Varified phone number

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc1}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}     
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"    	"${PAYTM_LINKED_NUMBER_REQUIRED}"
       
JD-TC-Update Account Payment Settings-UH5
       [Documentation]   Provider try to update payment setting without pancard Number

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}  ${EMPTY}  ${bankAccountNumber}  ${bankName}  ${ifsc1}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}     
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"
       
JD-TC-Update Account Payment Settings-UH6
       [Documentation]   Provider try to update payment setting without account number

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${phone_no}=   Random Int   min=1111111111   max=9999999999
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${phone_no}  ${panCardNumber}  ${EMPTY}  ${bankName}  ${ifsc1}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}     
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"
       
JD-TC-Update Account Payment Settings-UH7
       [Documentation]   Provider try to update payment setting without Bank Name

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${phone_no1}=   Random Int   min=1111111111   max=9999999999
       Set Suite Variable   ${phone_no1}
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${phone_no1}  ${panCardNumber}  ${bankAccountNumber}  ${EMPTY}  ${ifsc1}  ${panname}  ${firstname}   ${city}  ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"
       
JD-TC-Update Account Payment Settings-UH8
       [Documentation]   Provider try to update payment setting without ifsc Code

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${phone_no1}  ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${EMPTY}  ${panname}  ${firstname}   ${city}  ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"                             
          
JD-TC-Update Account Payment Settings-UH9
       [Documentation]   Provider try to update payment setting without Name on pancard

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${phone_no1}  ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc1}  ${EMPTY}  ${firstname}  ${city}  ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"     
       
JD-TC-Update Account Payment Settings-UH10
       [Documentation]   Provider try to update payment setting without Account holder's name

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${phone_no1}  ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc1}  ${panname}  ${EMPTY}  ${city}  ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"   
       
JD-TC-Update Account Payment Settings-UH11
       [Documentation]   Provider try to update payment setting without Brach city

       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Update Account Payment Settings  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${phone_no1}  ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc1}  ${panname}  ${firstname}   ${EMPTY}  ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${PAYU_ACCOUNTDETAILS_REQUIRED}"                                                                          
       
JD-TC-Update Account Payment Settings-UH12
       [Documentation]   Basic package Provider try to update payment setting 

       ${resp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
       Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
       ${first_name}=   FakerLibrary.first_name
       ${last_name}=    FakerLibrary.last_name
       ${email}=  Set Variable  ${P_Email}${first_name}.${test_mail}
       ${pkg_id}=   get_highest_license_pkg
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+51160
       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n} 
       ${resp}=  Account SignUp  ${first_name}  ${last_name}   ${email}  ${d1}  ${sd1}  ${PUSERNAME}    ${pkg_id[0]}
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${email}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       sleep  2s
       ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${acct_id1}=  get_acc_id  ${PUSERNAME}
       ${resp}=   Update Account Payment Settings  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${PUSERNAME_B}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessStatus}   ${accounttype}   
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response  ${resp}  accountId=${acct_id1}  payUVerified=${bool[0]}  onlinePayment=${bool[0]}  payTm=${bool[1]}  dcOrCcOrNb=${bool[0]}
      

JD-TC-Update Account Payment Settings-7
    [Documentation]   provider try to update payment setting without basic details ,only OnlinePayment field

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}   ${GST_num} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}   ${businessStatus}   ${accounttype}     
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable  ${pid}
    ${merchnt_id}=   Random Int  min=1111111  max=5555555
    ${resp}=  SetMerchantId  ${pid}  ${merchnt_id}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  payuVerify  ${pid}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings  ${bool[1]}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${None}  ${None}  
    Should Be Equal As Strings    ${resp.status_code}  200
     

      