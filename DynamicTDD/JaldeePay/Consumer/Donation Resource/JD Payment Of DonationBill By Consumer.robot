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
${SERVICE1}   MakeUp
${SERVICE2}   Coloring
${SERVICE3}   Painting
${digits}       0123456789

*** Test Cases ***

JD-TC-DonationPayment-1
        [Documentation]   Consumer do payment of a donation bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME51}
        clear_service   ${PUSERNAME51}
        clear_queue      ${PUSERNAME51}
        clear_location   ${PUSERNAME51}

        ${pid}=  get_acc_id  ${PUSERNAME51}
        Set Suite Variable  ${pid}
        
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
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME8}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME51}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        # ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}
        # ${don_amt_float}=  twodigitfloat  ${don_amt}
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

        # ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

        ${resp}=  Get Payment Details By UUId    ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${mock_id}  ${resp.json()[0]['id']}
        # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        # Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[4]}  
        # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[2]}  
        # Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt} 
        Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

        ${resp}=  Get Individual Payment Records  ${mock_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()['amount']}  ${don_amt}
        Should Be Equal As Strings  ${resp.json()['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()['paymentGateway']}  RAZORPAY 

        ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}  
        Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
        # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY 

        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}

        ${resp}=   Consumer Logout         
        Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-DonationPayment-UH1
        [Documentation]  DonationPayment  using another consumer id with empty donation

        ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME51}
        clear_service   ${PUSERNAME51}
        clear_queue      ${PUSERNAME51}
        clear_location   ${PUSERNAME51}

        ${pid}=  get_acc_id  ${PUSERNAME51}
        Set Suite Variable  ${pid}
        
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

        # ${resp}=  Get jp finance settings
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        
        # IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        #         ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        #         Log  ${resp1.content}
        #         Should Be Equal As Strings  ${resp1.status_code}  200
        # END

        # ${resp}=  Get jp finance settings    
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE2}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id10}=  get_id  ${CUSERNAME10}
        Set Suite Variable  ${con_id10}
        ${acc_id}=  get_acc_id  ${PUSERNAME51}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        # ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}
        # ${don_amt_float}=  twodigitfloat  ${don_amt}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${don_amt_float}=  twodigitfloat  ${don_amt}
        Set Suite Variable  ${don_amt}
        
        ${resp}=  Donation By Consumer  ${con_id10}  ${sid2}  ${loc_id1}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id2}  ${don_id[0]}
        # ${resp}=  Get Consumer Donation By Id  ${don_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200 
        # Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        # Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        # ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        # Should Be Equal As Strings    ${resp.status_code}   200
        # ${con_id10}=  get_id  ${CUSERNAME10}
        ${resp}=   Consumer Logout         
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        ${con_id10}=  get_id  ${CUSERNAME10}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}   ${don_id2}  ${sid2}  ${bool[0]}   ${bool[1]}  ${con_id10}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-DonationPayment-UH2
        [Documentation]   make payment by provider login with empty donation id

        ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${acc_id12}=  get_acc_id  ${PUSERNAME101}
        clear_service   ${PUSERNAME101}
        clear_queue      ${PUSERNAME101}
        clear_location   ${PUSERNAME101}

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

        Set Suite Variable  ${acc_id12}
        ${resp}=  Make payment Consumer Mock  ${acc_id12}  ${don_amt}  ${purpose[5]}  0000  ${sid2}  ${bool[0]}   ${bool[1]}  ${con_id10}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${INVALID_YNWUUID}"   

JD-TC-DonationPayment-UH3  
        [Documentation]   get bill without login      
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

