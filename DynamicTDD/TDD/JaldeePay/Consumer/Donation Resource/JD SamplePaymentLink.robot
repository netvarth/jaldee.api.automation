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


*** Test Cases ***

JD-TC-GetDonationPaymentViaLink-1

        [Documentation]   Consumer Get Donation Payment Via Link

        ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        clear_queue      ${PUSERNAME150}
        clear_location   ${PUSERNAME150}
        clear_service    ${PUSERNAME150}
        clear_customer   ${PUSERNAME150}

        ${pid}=  get_acc_id  ${PUSERNAME150}
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

        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']} 

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
        # log  ${sid1}
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
        # log  ${resp.json()}

        ${con_id}=  get_id  ${CUSERNAME5}
        Set Suite Variable  ${con_id}
        # ${c_acc_id}=  get_acc_id  ${CUSERNAME5}
        # Set Suite Variable  ${c_acc_id}
        # ${acc_id}=  get_acc_id  ${PUSERNAME150}
        # Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        # log  ${con_id}
        # log  ${c_acc_id}
        # log  ${acc_id}

        ${don_amt1}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
        ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
        ${don_amt1}=  Convert To Number  ${don_amt1}  1
        Set Suite Variable  ${don_amt1}
        ${don_amt_float1}=  twodigitfloat  ${don_amt1}

        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt1}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        # log  ${resp.json()['uid']}
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id1}  ${don_id[0]}

        ${resp}=   Consumer Login  ${CUSERNAME5}   ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${donar_fname}=  FakerLibrary.first_name
        Set Suite Variable  ${donar_fname}
        ${donar_lname}=  FakerLibrary.last_name
        Set Suite Variable  ${donar_lname}
        ${address}=  get_address
        Set Suite Variable  ${address}
        ${ph1}=  Evaluate  ${CUSERNAME5}+58963
        Set Suite Variable  ${ph1}
        
        ${note}=  FakerLibrary.sentence
        ${donorEmail}=  FakerLibrary.email
        ${resp}=  Create Payment Link For Donation  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${pay_link}  ${resp.json()['paylink']}
        Set Suite Variable  ${uuid1}  ${resp.json()['uuid']}
        # log  ${resp.json()}
        # log  ${resp.status_code}
        # Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  get donation details  ${pay_link}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        # .........verify the donation details from the above response.........


        # log  ${resp.json()}
        # log  ${resp.status_code}
        # Should Be Equal As Strings  ${resp.status_code}  200
        
        ${don_amt}=   Random Int   min=500   max=1000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${don_amt}=  Convert To Integer  ${don_amt}
        Set Suite Variable  ${don_amt} 
        ${isInternational}=  Convert To Boolean  ${isInternational}
        ${serviceId}=  Convert To Integer  ${serviceId}
        ${resp}=  donation payment via link  ${pid}  ${con_id}  ${don_amt}  ${isInternational}  ${paymentMode}  ${purpose}  ${sid1}  ${source}  ${uuid1}  ${pay_link}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        # .........verify the payment details from the above response.........

        # log  ${resp.json()}
        # log  ${resp.status_code}


*** Comments ***
JD-TC-GetDonationPaymentViaLink-2
    [Documentation]  giving the invalid account id for making payment via link.
