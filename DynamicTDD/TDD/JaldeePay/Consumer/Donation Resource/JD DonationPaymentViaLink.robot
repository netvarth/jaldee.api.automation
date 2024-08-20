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

${countryCode}  +91
${purpose}  donation
${source}  Desktop
${isInternational}  false
${paymentMode}  Mock
${serviceId}  0

${in_pid}  420
${l_pid}  127051
${ng_pid}  -552
${sp_char_pid}  28$
${In_con_id}  1000
${sp_char_con_id}  100o#
${digits_in_donar_fname}  netvarth2019
${digits_in_donar_lname}  netvarth2019
${in_loc_id1}  -552
${p_random_DAY}  1827-05-09
${0_don_amt1}  0
${ng_don_amt1}  -552
${w_sid1}  483
${t_ph1}  17100589
${in_countryCode}  +11
${high_don_amt1}  552000000000000
${aplha_don_amt1}  ox55200000o000

${In_pay_link}  33198776027eenableble
${Wrong_pay_link}  989465747190eenetvarth



*** Test Cases ***

JD-TC-DonationPaymentViaLink-1

        [Documentation]  Consumer genersting the payment link and making the doation payment using the generated payment link. 

        ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        clear_queue      ${PUSERNAME115}
        clear_location   ${PUSERNAME115}
        clear_service    ${PUSERNAME115}
        clear_customer   ${PUSERNAME115}

        ${pid}=  get_acc_id  ${PUSERNAME115}
        Set Suite Variable  ${pid}
        
        log  ${pid}
        
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

        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

        ${description}=  FakerLibrary.sentence
        Set Suite Variable  ${description}
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
        Set Suite Variable  ${service_duration}
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

        ${resp}=   Provider Logout
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Suite Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt1}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id1}  ${don_id[0]}

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${donar_fname}=  FakerLibrary.first_name
        Set Test Variable  ${donar_fname}
        ${donar_lname}=  FakerLibrary.last_name
        Set Test Variable  ${donar_lname}
        ${address}=  get_address
        Set Test Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Test Variable  ${ph1}
        
        ${note}=  FakerLibrary.sentence
        ${donorEmail}=  FakerLibrary.email
        ${resp}=  Create Payment Link For Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Suite Variable  ${uuid1}  ${resp.json()['uuid']}
        
        ${resp}=  get donation details  ${pay_link}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}  ${lname1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['description']}  ${description}
        Should Be Equal As Strings  ${resp.json()['service']['serviceDuration']}  ${service_duration}
        Should Be Equal As Strings  ${resp.json()['service']['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service']['maxDonationAmount']}  ${max_don_amt}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['uid']}  ${uuid1}
        Should Be Equal As Strings  ${resp.json()['donationAmount']}  ${don_amt1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donorEmail']}  ${donorEmail}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}
        
        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   donation payment via link  ${pid}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}   ${pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings   ${resp.json()['amount']}  ${don_amt}


JD-TC-DonationPaymentViaLink-2
        
        [Documentation]  Making the donation payment using the payment link by giving the another  consumer id.
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
        
        ${In_con_id}=  get_id  ${CUSERNAME10}
        Set Test Variable  ${In_con_id}
        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${In_con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}   ${pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings   ${resp.json()['amount']}  ${don_amt}


JD-TC-DonationPaymentViaLink-3
        
        [Documentation]  Making the donation payment using the payment link by giving the Invalid account id of the consumer .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${In_con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        # Should Be Equal As Strings   ${resp.json()['amount']}  ${don_amt}


JD-TC-DonationPaymentViaLink-UH1
        
        [Documentation]  Making the donation payment using the payment link by giving the donation amount as 0 .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${con_id}  ${0_don_amt1}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  $${uuid1}  {pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   422
        Should Be Equal As Strings    ${resp.json()}   ${CANNOT_ACCEPT_PAY_SINCE_AMOUNT_IS_ZERO}


JD-TC-DonationPaymentViaLink-UH2
        
        [Documentation]  Making the donation payment using the payment link by giving the negative integer value in donation amount .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${con_id}  ${ng_don_amt1}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   422
        Should Be Equal As Strings    ${resp.json()}   ${INVALID_PAYMENT_AMOUNT}


JD-TC-DonationPaymentViaLink-UH3
        
        [Documentation]  Making the donation payment using the payment link by giving the negative integer value in donation amount .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${con_id}  ${high_don_amt1}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   422
        Should Be Equal As Strings    ${resp.json()}   ${HIGHER_PAYMENT_AMOUNT}


JD-TC-DonationPaymentViaLink-UH4
        
        [Documentation]  Making the donation payment using the payment link by giving the invalid account id of the provider.
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${in_pid}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}


JD-TC-DonationPaymentViaLink-UH5
        
        [Documentation]  Making the donation payment using the payment link by giving the negative integer value account id of the provider.
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${ng_pid}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}


JD-TC-DonationPaymentViaLink-UH6
        
        [Documentation]  Making the donation payment using the payment link by giving the special character in account id of the provider.
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${sp_char_pid}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}

    
JD-TC-DonationPaymentViaLink-UH7
        
        [Documentation]  Making the donation payment using the payment link by giving the long integer value in account id of the provider.
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${l_pid}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}


JD-TC-DonationPaymentViaLink-UH8
        
        [Documentation]  Making the donation payment using the payment link by giving the blank account id of the provider .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${empty}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}


JD-TC-DonationPaymentViaLink-UH9
        
        [Documentation]  Making the donation payment using the payment link by giving the blank account id of the consumer .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${empty}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}


JD-TC-DonationPaymentViaLink-UH10
        
        [Documentation]  Making the donation payment using the payment link by giving the special charaters in account id of the consumer .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=   Donation Payment Via Link  ${pid}  ${sp_char_con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}