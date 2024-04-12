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

${in_acc_id}  0
${lo_acc_id}  127051
${ng_acc_id}  -552
${digits_in_donar_fname}  netvarth2019
${digits_in_donar_lname}  netvarth2019
${in_loc_id1}  -552
${p_random_DAY}  1827-05-09
${0_don_amt1}  0
${ng_don_amt1}  -552
${w_sid1}  483
${t_ph1}  17100589
${in_countryCode}  +11
${large_don_amt1}  552000000000000
${aplha_don_amt1}  ox55200000o000

${In_pay_link}  33198776027eenableble
${Wrong_pay_link}  989465747190eenetvarth



*** Test Cases ***

JD-TC-GetDonationDetails-1

        [Documentation]   Consumer Get Donation Payment Via Link and get the details of the donation.

        ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
*** Comments ***
        clear_queue      ${PUSERNAME150}
        clear_location   ${PUSERNAME150}
        clear_service    ${PUSERNAME150}
        clear_customer   ${PUSERNAME150}

        ${pid}=  get_acc_id  ${PUSERNAME150}
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
        log  ${pay_link}
        
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


JD-TC-GetDonationDetails-2

        [Documentation]  Get the details of the donation by giving the digits in first_name for donar.

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${donar_lname}=  FakerLibrary.last_name
        Set Test Variable  ${donar_lname}
        ${address}=  get_address
        Set Test Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Test Variable  ${ph1}
        
        ${note}=  FakerLibrary.sentence
        ${donorEmail}=  FakerLibrary.email
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${digits_in_donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

        ${resp}=  get donation details  ${pay_link}
        log  ${resp.json()}
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
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${digits_in_donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donorEmail']}  ${donorEmail}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}


JD-TC-GetDonationDetails-3

        [Documentation]  Get the details of the donation by giving the previous random date instead of current date.

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${donar_fname}=  FakerLibrary.first_name
        Set Test Variable  ${donar_fname}
        ${address}=  get_address
        Set Test Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Test Variable  ${ph1}
        
        ${note}=  FakerLibrary.sentence
        ${donorEmail}=  FakerLibrary.email
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${digits_in_donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

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
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${digits_in_donar_lname}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donorEmail']}  ${donorEmail}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}


JD-TC-GetDonationDetails-4

        [Documentation]  Get the details of the Donation by giving the previous random date instead of current date .
        
        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

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
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${p_random_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        Should Be Equal As Strings  ${resp.status_code}  200
        log  ${resp.json()}
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}
        Should Be Equal As Strings  ${resp.status_code}  200

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


JD-TC-GetDonationDetails-5

        [Documentation]  Get the details of the donation by giving the donation amount as 0 .

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

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
        ${0_don_amt1}=  Convert To Number  ${0_don_amt1}
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${0_don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

         ${resp}=  get donation details  ${pay_link}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['date']}  ${CUR_DAY}
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
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donorEmail']}  ${donorEmail}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}


JD-TC-GetDonationDetails-6

        [Documentation]  Get the details of the Donation by giving the negative donation amount .

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
        
        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

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
        ${ng_don_amt1}=  Convert To Number  ${ng_don_amt1}
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${ng_don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

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
        Should Be Equal As Strings  ${resp.json()['donationAmount']}  ${ng_don_amt1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donorEmail']}  ${donorEmail}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}
        


JD-TC-GetDonationDetails-7

        [Documentation]  Get the details of thr donation by giving the empty donar last name .

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${donar_fname}=  FakerLibrary.first_name
        Set Test Variable  ${donar_fname}
        ${address}=  get_address
        Set Test Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Test Variable  ${ph1}
        
        ${note}=  FakerLibrary.sentence
        ${donorEmail}=  FakerLibrary.email
        ${ng_don_amt1}=  Convert To Number  ${ng_don_amt1}
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${empty}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

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
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${empty}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}


JD-TC-GetDonationDetails-8

        [Documentation]  Get the details of the donation by giving the empty donar email .

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${donar_fname}=  FakerLibrary.first_name
        Set Test Variable  ${donar_fname}
        ${donar_lname}=  FakerLibrary.last_name
        Set Test Variable  ${donar_lname}
        ${address}=  get_address
        Set Test Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Test Variable  ${ph1}
        
        ${note}=  FakerLibrary.sentence
        ${ng_don_amt1}=  Convert To Number  ${ng_don_amt1}
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${empty}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

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
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}
        

JD-TC-GetDonationDetails-9

        [Documentation]  Get the details of the donation by giving the empty note .

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${donar_fname}=  FakerLibrary.first_name
        Set Test Variable  ${donar_fname}
        ${donar_lname}=  FakerLibrary.last_name
        Set Test Variable  ${donar_lname}
        ${address}=  get_address
        Set Test Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Test Variable  ${ph1}
        
        ${donorEmail}=  FakerLibrary.email
        ${ng_don_amt1}=  Convert To Number  ${ng_don_amt1}
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${empty}  ${sid1}  ${pid}
        log  ${resp.json()}
        log  ${resp.status_code}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

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
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}


JD-TC-GetDonationDetails-10

        [Documentation]  get the details of the donation by giving the very large donation amount.

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Test Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

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
        ${large_don_amt1}=  Convert To Number  ${large_don_amt1}
        ${resp}=  create payment link for Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${large_don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Test Variable  ${uuid1}  ${resp.json()['uuid']}

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
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donorPhoneNumber']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donorEmail']}  ${donorEmail}
        Should Be Equal As Strings  ${resp.json()['note']}  ${note}
        Should Be Equal As Strings   ${resp.json()['accountId']}  ${pid}
        
        
JD-TC-GetDonationDetails-UH1

        [Documentation]   get the details of the donation giving the invalid payment link.

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${resp}=  get donation details  ${In_pay_link}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  404
        Should Be Equal As Strings    ${resp.json()}   ${INVALID_GEN_ID}


JD-TC-GetDonationDetails-UH2

        [Documentation]  get the details of the donation by giving the wrong payment link.

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${resp}=  get donation details  ${Wrong_pay_link}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  404
        Should Be Equal As Strings    ${resp.json()}   ${INVALID_GEN_ID}





