*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Donation
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
${SERVICE1}   MakeUp11
${SERVICE2}   Coloring
${SERVICE3}   Painting
${a}   0
${digits}       0123456789
${self}               0
@{provider_list}
${start}              100

*** Test Cases ***

JD-TC-DonationPayment-1
        [Documentation]   Provider Get Bill of a Donation
        ${resp}=   Billable
        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=10000   max=50000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}  1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME8}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${don_amt_float}=  twodigitfloat  ${don_amt}
        Set Suite Variable  ${don_amt}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
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
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

        Log  ${PUSERNAME}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Payment By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_id}  ${resp.json()[0]['id']}
        # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[2]}  
        # Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt} 
        Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

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
        Should Be Equal As Strings  ${resp.json()['paymentGateway']}  RAZORPAY 


JD-TC-DonationPayment-UH1
        [Documentation]  Provider trying to accept payment of donation amount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_PH}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200  
        ${resp}=  Accept Payment  ${don_id}  ${payment_modes[0]}  ${don_amt}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${ACCEPT_PAY_NOT_ALLOWED}"


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
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        clear_location   ${PUSERNAME${a}}
        clear_service    ${PUSERNAME${a}}
        ${acc_id}=  get_acc_id  ${PUSERNAME${a}}
        Set Suite Variable   ${acc_id}
        
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