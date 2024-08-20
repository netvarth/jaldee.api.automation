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
${digits}       0123456789

*** Test Cases ***

JD-TC-GetDonations-1
        [Documentation]   Consumer Get Donation By Id
        ${resp}=  Encrypted Provider Login  ${PUSERNAME57}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # delete_donation_service  ${PUSERNAME57}
        # clear_service   ${PUSERNAME57}
        clear_queue      ${PUSERNAME57}
        clear_location   ${PUSERNAME57}

        ${pid}=  get_acc_id  ${PUSERNAME57}
        Set Suite Variable  ${pid}
        
        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

        ${resp}=  Get Account Settings
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
        Set Suite Variable  ${min_don_amt}
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

        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME10}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME57}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        # ${don_amt1}=  Evaluate  ${min_don_amt}*${multiples[0]}
        # Set Suite Variable  ${don_amt1}
        # ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Suite Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt1}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id1}  ${don_id[0]}

        ${donar_fname}=  FakerLibrary.first_name
        Set Suite Variable  ${donar_fname}
        ${donar_lname}=  FakerLibrary.last_name
        Set Suite Variable  ${donar_lname}
        ${address}=  get_address
        Set Suite Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME10}+58963
        Set Suite Variable  ${ph1}

        # ${don_amt2}=  Evaluate  ${min_don_amt}*${multiples[0]}
        # Set Suite Variable  ${don_amt2}
        # ${don_amt_float2}=  twodigitfloat  ${don_amt2}

        ${don_amt2}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt2}%${multiples[0]}
        ${don_amt2}=  Evaluate  ${don_amt2}-${mod}
        ${don_amt2}=  Convert To Number  ${don_amt2}  1
        Set Suite Variable  ${don_amt2}
        ${don_amt_float2}=  twodigitfloat  ${don_amt2}

        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  ${don_amt2}  ${donar_fname}  ${donar_lname}  ${address}  ${ph1}  ${P_Email}${donar_fname}.${test_mail}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id2}  ${don_id[0]}

        # ${resp}=  Get Bill By consumer  ${don_id1}  ${acc_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt1}  ${purpose[5]}  ${don_id1}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  Make payment Consumer Mock  ${don_amt1}  ${bool[1]}  ${don_id1}  ${acc_id}  ${purpose[5]}  ${con_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  Get Bill By consumer  ${don_id2}  ${acc_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt2}  ${purpose[5]}  ${don_id2}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=  Make payment Consumer Mock  ${don_amt2}  ${bool[1]}  ${don_id2}  ${acc_id}  ${purpose[5]}  ${con_id}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        sleep  02s

        ${resp}=  Get Donations By Consumer
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response List  ${resp}  1   uid=${don_id1}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt1}
        Verify Response List  ${resp}  0   uid=${don_id2}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt2}
        Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['firstName']}  ${donar_fname}     
        Should Be Equal As Strings  ${resp.json()[0]['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['phoneNo']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['email']}  ${P_Email}${donar_fname}.${test_mail}

JD-TC-GetDonations-2
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donations By Consumer  date-eq=${CUR_DAY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response List  ${resp}  1   uid=${don_id1}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt1}
        Verify Response List  ${resp}  0   uid=${don_id2}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt2}
        Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['phoneNo']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['email']}  ${P_Email}${donar_fname}.${test_mail}

JD-TC-GetDonations-3
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donations By Consumer  service-eq=${sid2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response List  ${resp}  0    uid=${don_id2}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt2}
        Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${loc_id1}

JD-TC-GetDonations-4
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donations By Consumer  location-eq=${loc_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response List  ${resp}  1   uid=${don_id1}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt1}
        Verify Response List  ${resp}  0   uid=${don_id2}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt2}
        Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['phoneNo']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['email']}  ${P_Email}${donar_fname}.${test_mail}

JD-TC-GetDonations-5
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        sleep   2s
        ${resp}=  Get Donations By Consumer  donationAmount-eq=${don_amt1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response List  ${resp}  0    uid=${don_id1}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt1}
        Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${loc_id1}

JD-TC-GetDonations-6
        [Documentation]   Consumer Get Donations Count
        ${resp}=   Consumer Login  ${CUSERNAME10}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donations By Consumer  billPaymentStatus-eq=${paymentStatus[2]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response List  ${resp}  1   uid=${don_id1}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt1}
        Verify Response List  ${resp}  0   uid=${don_id2}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[2]}  donationAmount=${don_amt2}
        Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['phoneNo']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()[0]['donor']['email']}  ${P_Email}${donar_fname}.${test_mail}

JD-TC-GetDonations-7
        [Documentation]   Consumer get donations but there is no donation done by consumer
        ${resp}=   Consumer Login  ${CUSERNAME19}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donations By Consumer
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()}   []

JD-TC-GetDonations -UH1
        [Documentation]   get a donation by id without login      
        ${resp}=  Get Donations By Consumer
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


