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

JD-TC-DonationBill-1
        [Documentation]   Consumer Get Bill of a Donation (No Tax Enabled)
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME25}
        clear_service   ${PUSERNAME25}
        clear_queue      ${PUSERNAME25}
        clear_location   ${PUSERNAME25}

        ${resp}=  Get Account Payment Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

        ${resp}=   Get Account Payment Settings 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        
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

        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME8}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME25}
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
        Set Suite Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${fname1}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${lname1}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${prov_consid}  ${resp.json()[0]['id']}

        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        
        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${don_id}  netTotal=${don_amt}  billStatus=New  billViewStatus=Notshow  netRate=${don_amt}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${don_amt}  taxableTotal=0.0  totalTaxAmount=0.0  taxPercentage=0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['maxDonationAmount']}  ${max_don_amt}
        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${prov_consid}


JD-TC-DonationBill-2
        [Documentation]   Consumer Get Bill of a Donation where donation service has tax
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME25}
        clear_service   ${PUSERNAME25}
        clear_queue      ${PUSERNAME25}
        clear_location   ${PUSERNAME25}
        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
        ${gstper}=  Random Element  ${gstpercentage}
        ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Tax
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Tax Percentage
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Test Variable  ${tax_per}  ${resp.json()['taxPercentage']}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500

        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[1]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${con_id}=  get_id  ${CUSERNAME8}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME25}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${donar_fname}=  FakerLibrary.firstname
        ${donar_lname}=  FakerLibrary.lastname
        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${donar_fname}  ${donar_lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${don_id}  ${don_id[0]}
        ${resp}=  Get Consumer Donation By Id  ${don_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}
        Should Be Equal As Strings  ${resp.json()['donor']['firstName']}  ${donar_fname}
        Should Be Equal As Strings  ${resp.json()['donor']['lastName']}  ${donar_lname}

        ${taxable_amt}=  Evaluate  ${don_amt}*(${tax_per}/100)
        ${taxable_amt}=  Convert To Number  ${taxable_amt}   1
        ${don_amt_with_tax}=  Evaluate  ${don_amt}+${taxable_amt}

        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${don_id}  netTotal=${don_amt}  billStatus=New   billViewStatus=Notshow   netRate=${don_amt_with_tax}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${don_amt_with_tax}  taxableTotal=${don_amt}  totalTaxAmount=${taxable_amt}  taxPercentage=${tax_per}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${tax_per}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['maxDonationAmount']}  ${max_don_amt}
        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${prov_consid}
        
JD-TC-DonationBill-UH1
        [Documentation]  DonationBill  using another consumer uuid
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings  "${resp.json()}"  "${YOU_CANNOT_VIEW_THE_BILL}"

JD-TC-DonationBill-UH2
        [Documentation]   get bill by provider
        ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
        Should Be Equal As Strings    ${resp.status_code}   200 
        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings  "${resp.json()}"  "${YOU_CANNOT_VIEW_THE_BILL}"   

JD-TC-DonationBill-UH3  
        [Documentation]   get bill without login      
        ${resp}=  Get Bill By consumer  ${don_id}   ${acc_id}   
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

JD-TC-DonationBill-UH4
        [Documentation]  Getting donation bill with invalid donation id
        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Bill By consumer  000  ${acc_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"    "${INVALID_UID}"
JD-TC-DonationBill-UH5
        [Documentation]  Getting donation bill with invalid account id
        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Bill By consumer  ${don_id}  000
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  404
        Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"
