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
${SERVICE}    physicalservice

*** Test Cases ***

JD-TC-ConsumerDonation-1
        [Documentation]   Consumer doing a donation
        ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME206}
        clear_service   ${PUSERNAME206}
        clear_queue      ${PUSERNAME206}
        clear_location   ${PUSERNAME206}
        
        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

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
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Create Sample Service  ${SERVICE}
        Set Suite Variable    ${ser_id1}    ${resp}  

        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME9}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME206}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${lname1}

JD-TC-ConsumerDonation-2
        [Documentation]   Consumer doing a donation for another service
        ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
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
        ${resp}=  Create Donation Service  ${SERVICE2}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}   ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid2}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${lname1}

JD-TC-ConsumerDonation-3
        [Documentation]   Consumer doing a donation for another service in another location
        ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        # ${city}=   FakerLibrary.state
        # Set Suite Variable  ${city}
        # ${latti}=  get_latitude
        # Set Suite Variable  ${latti}
        # ${longi}=  get_longitude
        # Set Suite Variable  ${longi}
        # ${postcode}=  FakerLibrary.postcode
        # Set Suite Variable  ${postcode}
        # ${address}=  get_address
        # Set Suite Variable  ${address}
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        Set Suite Variable  ${city}
        Set Suite Variable  ${latti}
        Set Suite Variable  ${longi}
        Set Suite Variable  ${postcode}
        Set Suite Variable  ${address}
        ${parking}    Random Element   ${parkingType}
        Set Suite Variable  ${parking}
        ${24hours}    Random Element    ${bool}
        Set Suite Variable  ${24hours}
        ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
        ${sTime}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime}
        ${eTime}=  add_timezone_time  ${tz}  0  30  
        Set Suite Variable   ${eTime}
        ${resp}=  Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid2}  ${resp.json()}
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
        ${resp}=  Create Donation Service  ${SERVICE3}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid3}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        Set Suite Variable  ${don_amt}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid3}  ${lid2}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid2}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${lname1}

JD-TC-ConsumerDonation-4
        [Documentation]   Consumer doing a donation for same service with same amount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Donation By Consumer  ${con_id}  ${sid3}  ${lid2}   ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid2}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${lname1}

JD-TC-ConsumerDonation-5
        [Documentation]   Consumer doing a donation for a donar
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${donar_fname}=  FakerLibrary.first_name
        ${donar_lname}=  FakerLibrary.last_name
        ${address}=  get_address
        ${ph1}=  Evaluate  ${CUSERNAME9}+58963
        ${resp}=  Donation By Consumer  ${con_id}  ${sid3}  ${lid2}  ${don_amt}  ${donar_fname}  ${donar_lname}  ${address}  ${ph1}  ${P_Email}${donar_fname}.${test_mail}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid3}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid2}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}
        Should Be Equal As Strings  ${resp.json()['donor']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()['donor']['phoneNo']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['donor']['email']}  ${P_Email}${donar_fname}.${test_mail}

JD-TC-ConsumerDonation-UH1
        [Documentation]   Consumer doing a donation for a amount that not in range
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}   10  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422  
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_AMOUNT_RANGE}"

JD-TC-ConsumerDonation-UH2
        [Documentation]   Consumer doing a donation with empty amount
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  ${EMPTY}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422  
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_AMOUNT_REQUIRED}"

JD-TC-ConsumerDonation-UH3
        [Documentation]   Consumer doing a donation with invalid consumer id
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  000  ${sid2}  ${loc_id1}  ${don_amt}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_FOUND}"

JD-TC-ConsumerDonation-UH4
        [Documentation]   Consumer doing a donation with invalid service id
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  ${con_id}  000  ${loc_id1}  ${don_amt}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_FOUND}"

JD-TC-ConsumerDonation-UH5
        [Documentation]   Consumer doing a donation with invalid location id
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  000  ${don_amt}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_NOT_FOUND}"

JD-TC-ConsumerDonation-UH6
        [Documentation]   Consumer doing a donation For a Provider who has no donation services
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${acc_id}=  get_acc_id  ${PUSERNAME122}

        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
        
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  ${don_amt}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  401 
        Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-ConsumerDonation -UH7
       [Documentation]   Consumer doing a donation without login      
       ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  ${don_amt}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-ConsumerDonation-UH8
        [Documentation]   Consumer doing a donation with wrong multiples of donation amount
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200   
        ${DONATION_AMOUNT_NOT_MULTIPLES}=  Format String  ${DONATION_AMOUNT_NOT_MULTIPLES}  ${multiples[0]}
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  5001  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422  
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_AMOUNT_NOT_MULTIPLES}"

JD-TC-ConsumerDonation-UH9
        [Documentation]   Consumer doing a donation with physical service
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  ${con_id}  ${ser_id1}  ${loc_id1}  ${don_amt}  ${fname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_SERVICE_REQUIRED}"

JD-TC-ConsumerDonation-UH10
        [Documentation]   Consumer doing a donation without donor name
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Donation By Consumer  ${con_id}  ${sid2}  ${loc_id1}  ${don_amt}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${DONOR_NAME_REQUIRED}"


JD-TC-ConsumerDonation-6
        [Documentation]   International Consumer doing a donation
        ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME206}
        clear_service   ${PUSERNAME206}
        clear_queue      ${PUSERNAME206}
        clear_location   ${PUSERNAME206}
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
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Create Sample Service  ${SERVICE}
        Set Suite Variable    ${ser_id1}    ${resp} 

        ${PO_Number}=  random_phone_num_generator
        Log  ${PO_Number}
        ${country_code}=  Set Variable  ${PO_Number.country_code}
        ${CUSERPH0}=  Set Variable  ${PO_Number.national_number}
        ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
        ${firstname}=  FakerLibrary.first_name
        ${lastname}=  FakerLibrary.last_name
        ${address}=  FakerLibrary.address
        ${dob}=  FakerLibrary.Date
        ${gender}    Random Element    ${Genderlist}
        ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${CUSERPH0}.${test_mail}
        ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH0_EMAIL}  countryCode=+${country_code}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200 

        ${resp}=  Consumer Activation  ${CUSERPH0_EMAIL}  1
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Consumer Set Credential  ${CUSERPH0_EMAIL}  ${PASSWORD}  1  
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  countryCode=+${countryCode}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}

        # # ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        # # Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}


        ${con_id}=  get_id  ${CUSERPH0}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME206}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${lname1}
