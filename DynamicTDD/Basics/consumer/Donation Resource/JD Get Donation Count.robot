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
*** Variables ***
@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE2}   Coloring
${SERVICE3}   Painting
*** Test Cases ***

JD-TC-GetDonationsCount-1
        [Documentation]   Consumer Get Donations Count
        ${resp}=  Provider Login  ${PUSERNAME56}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME56}
        clear_service   ${PUSERNAME56}
        clear_queue      ${PUSERNAME56}
        clear_location   ${PUSERNAME56}

        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
        
        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp}  
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        Set Suite Variable  ${max_don_amt}
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE2}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME56}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  get_date
        Set Suite Variable  ${CUR_DAY}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Suite Variable  ${don_amt1}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt1}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id1}  ${don_id[0]}

        ${resp}=  Get Consumer Donation By Id  ${don_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Should Be Equal As Strings  ${resp.json()['consumer']['id']}       ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}        ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}       ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}   ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}    ${lname1}
        Should Be Equal As Strings  ${resp.json()['donationStatus']}       ${donation_status[0]}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}    ${paymentStatus[0]}
        Should Be Equal As Strings  ${resp.json()['donationAmount']}       ${don_amt1}

        ${resp}=  Provider Login  ${PUSERNAME56}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${prov_consid}  ${resp.json()[0]['id']}

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Get Bill By consumer  ${don_id1}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${prov_consid}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}        ${sid1}
        Should Be Equal As Strings  ${resp.json()['netTotal']}                       ${don_amt1}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}              ${paymentStatus[0]}
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt1}  ${purpose[5]}  ${don_id1}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

        ${resp}=  Get Payment Details By UUId    ${don_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}          ${don_id1}
        Should Be Equal As Strings  ${resp.json()[0]['status']}           ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}           ${don_amt1}  
        Should Be Equal As Strings  ${resp.json()[0]['custId']}           ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}      ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}        ${acc_id}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}   RAZORPAY  

        ${resp}=  Get Bill By consumer  ${don_id1}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${prov_consid}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}        ${sid1}
        Should Be Equal As Strings  ${resp.json()['netTotal']}                       ${don_amt1}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}              ${paymentStatus[2]}
        
        ${resp}=  Get Consumer Donation By Id  ${don_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Should Be Equal As Strings  ${resp.json()['consumer']['id']}       ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}        ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}       ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}   ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}    ${lname1}
        Should Be Equal As Strings  ${resp.json()['donationStatus']}       ${donation_status[1]}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}    ${paymentStatus[2]}
        Should Be Equal As Strings  ${resp.json()['donationAmount']}       ${don_amt1}

        ${donar_fname}=  FakerLibrary.first_name
        ${donar_lname}=  FakerLibrary.last_name
        ${address}=  get_address
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        ${don_amt2}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt2}%${multiples[0]}
        ${don_amt2}=  Evaluate  ${don_amt2}-${mod}
        ${don_amt2}=  Convert To Number  ${don_amt2}  1
        Set Suite Variable  ${don_amt2}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  ${don_amt2}  ${donar_fname}  ${donar_lname}  ${address}  ${ph1}  ${P_Email}${donar_fname}.${test_mail}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id2}  ${don_id[0]}

        ${resp}=  Get Consumer Donation By Id  ${don_id2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Should Be Equal As Strings  ${resp.json()['consumer']['id']}       ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}        ${sid2}
        Should Be Equal As Strings  ${resp.json()['location']['id']}       ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}   ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}    ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donationStatus']}       ${donation_status[0]}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}    ${paymentStatus[0]}
        Should Be Equal As Strings  ${resp.json()['donationAmount']}       ${don_amt2}

        ${resp}=  Get Bill By consumer  ${don_id2}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${prov_consid}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}        ${sid2}
        Should Be Equal As Strings  ${resp.json()['netTotal']}                       ${don_amt2}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}              ${paymentStatus[0]}
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt2}  ${purpose[5]}  ${don_id2}  ${sid2}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  Make payment Consumer Mock  ${don_amt2}  ${bool[1]}  ${don_id2}  ${acc_id}  ${purpose[5]}  ${con_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    
        ${resp}=  Get Payment Details By UUId    ${don_id2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}          ${don_id2}
        Should Be Equal As Strings  ${resp.json()[0]['status']}           ${cupnpaymentStatus[0]}  
        Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
        Should Be Equal As Strings  ${resp.json()[0]['amount']}           ${don_amt2}  
        Should Be Equal As Strings  ${resp.json()[0]['custId']}           ${con_id}   
        Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}      ${payment_modes[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}        ${acc_id}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[5]}  
        Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}   RAZORPAY  

        ${resp}=  Get Bill By consumer  ${don_id2}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${prov_consid}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}        ${sid2}
        Should Be Equal As Strings  ${resp.json()['netTotal']}                       ${don_amt2}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}              ${paymentStatus[2]}
        
        ${resp}=  Get Consumer Donation By Id  ${don_id2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Should Be Equal As Strings  ${resp.json()['consumer']['id']}       ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}        ${sid2}
        Should Be Equal As Strings  ${resp.json()['location']['id']}       ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}   ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}    ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donationStatus']}       ${donation_status[1]}
        Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}    ${paymentStatus[2]}
        Should Be Equal As Strings  ${resp.json()['donationAmount']}       ${don_amt2}

        ${resp}=  Get Payment Details By UUId    ${don_id2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
   
        ${resp}=  Get Donation Count By Consumer
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetDonationsCount-2
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Count By Consumer  date-eq=${CUR_DAY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetDonationsCount-3
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Count By Consumer  service-eq=${sid2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetDonationsCount-4
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Count By Consumer  location-eq=${loc_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetDonationsCount-5
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Count By Consumer  donationAmount-eq=${don_amt1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetDonationsCount-6
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Count By Consumer  billPaymentStatus-eq=${paymentStatus[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  0

JD-TC-GetDonationsCount-7
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Count By Consumer  billPaymentStatus-eq=${paymentStatus[2]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetDonationsCount -UH1
        [Documentation]   get a donation by id without login      
        ${resp}=  Get Donation Count By Consumer
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


