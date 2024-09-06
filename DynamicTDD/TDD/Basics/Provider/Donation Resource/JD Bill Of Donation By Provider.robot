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
${DisplayName1}   item1_DisplayName


*** Test Cases ***

JD-TC-DonationBill-1
        [Documentation]   Provider Get Bill of a Donation
        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME28}
        clear_service   ${PUSERNAME28}
        clear_queue      ${PUSERNAME28}
        clear_location   ${PUSERNAME28}

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
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500

        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}   ${bool[1]}    ${notifytype[2]}   ${total_amnt}    ${bool[0]}  ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME8}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME28}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}
        ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}

        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1

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
        Verify Response  ${resp}  uuid=${don_id}  netTotal=${don_amt}  billStatus=New  billViewStatus=Notshow  netRate=${don_amt}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${don_amt}  taxableTotal=0.0  totalTaxAmount=0.0  taxPercentage=0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['maxDonationAmount']}  ${max_don_amt}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${con_id}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  GetCustomer
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${don_id}  netTotal=${don_amt}  billStatus=New  billViewStatus=Notshow  netRate=${don_amt}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${don_amt}  taxableTotal=0.0  totalTaxAmount=0.0  taxPercentage=0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  0.0 
        Should Be Equal As Strings  ${resp.json()['service'][0]['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['maxDonationAmount']}  ${max_don_amt}
        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${con_id}

JD-TC-DonationBill-2
        [Documentation]   Provider Get Bill of a Donation where donation service has tax
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME25}
        clear_service   ${PUSERNAME25}
        clear_queue      ${PUSERNAME25}
        clear_location   ${PUSERNAME25}

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
        ${gstper}=  Random Element  ${gstpercentage}
        ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Tax
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Tax Percentage
        Log  ${resp.json()}
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
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[1]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
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
        ${taxable_amt}=  Evaluate  ${don_amt}*(${tax_per}/100)
        ${taxable_amt}=  twodigitfloat  ${taxable_amt}
        ${don_amt_with_tax}=  Evaluate  ${don_amt}+${taxable_amt}

        ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${don_id}  netTotal=${don_amt}  billStatus=New   billViewStatus=Notshow   netRate=${don_amt_with_tax}  
        ...  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${don_amt_with_tax}  taxableTotal=${don_amt}   taxPercentage=${tax_per}
        
        Should Be Equal As Numbers  ${resp.json()['totalTaxAmount']}  ${taxable_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${tax_per}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['maxDonationAmount']}  ${max_don_amt}
        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${con_id}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Bill By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${don_id}  netTotal=${don_amt}  billStatus=New   billViewStatus=Notshow   netRate=${don_amt_with_tax}  
        ...  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${don_amt_with_tax}  taxableTotal=${don_amt}  taxPercentage=${tax_per}
        
        Should Be Equal As Numbers  ${resp.json()['totalTaxAmount']}  ${taxable_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${tax_per}
        Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  0.0
        Should Be Equal As Strings  ${resp.json()['service'][0]['minDonationAmount']}  ${min_don_amt}
        Should Be Equal As Strings  ${resp.json()['service'][0]['maxDonationAmount']}  ${max_don_amt}
        Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['id']}  ${con_id}

JD-TC-DonationBill-UH1
        [Documentation]  Adding item to donation bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${short_desc}=   FakerLibrary.sentence  nb_words=3
        Log  ${short_desc}
        ${long_desc}=   FakerLibrary.sentence
        Log  ${long_desc}
        ${item1}=     FakerLibrary.word
        ${itemCode1}=     FakerLibrary.word
        # ${resp}=  Create Item   ${item1}  ${short_desc}  ${long_desc}  500  ${bool[1]}
        ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  500  ${bool[1]}   
        Log  ${resp.json()}  
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${itemId}  ${resp.json()}
        ${itemreason}=   FakerLibrary.word
        ${item}=  Item Bill  ${itemreason}  ${itemId}  1
        ${resp}=  Update Bill   ${don_id}  addItem   ${item}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_BILL_CAN_NOT_UPDATE}"

JD-TC-DonationBill-UH2
        [Documentation]   add service to bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${service}=  Service Bill  service forme  ${sid1}  1 
        ${resp}=  Update Bill   ${don_id}  addService   ${service}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_BILL_CAN_NOT_UPDATE}"

JD-TC- DonationBill-UH3
        [Documentation]  remove service from bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${service}=  Service Bill  service forme  ${sid1}  1 
        ${resp}=  Update Bill   ${don_id}  removeService   ${service}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_BILL_CAN_NOT_UPDATE}"

JD-TC- DonationBill-UH4
        [Documentation]  adjust service from bill
        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${service}=  Service Bill  service forme  ${sid1}  3 
        ${resp}=  Update Bill   ${don_id}  adjustService   ${service}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_BILL_CAN_NOT_UPDATE}"

JD-TC- DonationBill-UH5
        [Documentation]   add coupon to netBill
        ${data}=  FakerLibrary.Word
        ${coupon11}=  FakerLibrary.Word
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${coupon11}=    FakerLibrary.word
        ${desc}=  FakerLibrary.Sentence   nb_words=2
        ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
        ${cupn_code}=   FakerLibrary.word
        Set Suite Variable   ${cupn_code}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        ${ST_DAY}=  db.get_date_by_timezone  ${tz}
        ${EN_DAY}=  db.add_timezone_date  ${tz}   10
        ${min_bill_amount}=   Random Int   min=100   max=150
        ${max_disc_val}=   Random Int   min=100   max=500
        ${max_prov_use}=   Random Int   min=10   max=20
        ${book_channel}=   Create List   ${bookingChannel[0]}
        ${coupn_based}=  Create List   ${couponBasedOn[0]}
        ${tc}=  FakerLibrary.sentence
        ${services}=   Create list   ${sid1} 
        ${resp}=  Create Provider Coupon   ${coupon11}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${couponId}  ${resp.json()}
        # ${resp}=  Create Coupon  ${coupon11}  ${data}  20  Fixed
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${couponId}  ${resp.json()}
        ${resp}=  Get Bill By UUId  ${don_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}

        # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
        ${resp}=  Update Bill   ${don_id}  addProviderCoupons   ${cupn_code}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_BILL_CAN_NOT_UPDATE}"

JD-TC- DonationBill-UH6
        [Documentation]   add bill level discount
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${discount2}=  FakerLibrary.Word
        ${resp}=   Create Discount  ${discount2}   disc   100.0   Fixed   Predefine
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${discountId}   ${resp.json()}
        ${resp}=  Get Bill By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bid}  ${resp.json()['id']}
        ${disc1}=  Bill Discount Input  ${discountId}  pnote  cnote
        ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
        ${resp}=  Update Bill   ${don_id}  addBillLevelDiscount  ${bdisc}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${DONATION_BILL_CAN_NOT_UPDATE}"

JD-TC-DonationBill-UH7
        [Documentation]   Provider Get Bill of a Donation but bill not generated by consumer
        ${resp}=  Encrypted Provider Login  ${PUSERNAME29}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME29}
        clear_service   ${PUSERNAME29}
        clear_queue      ${PUSERNAME29}
        clear_location   ${PUSERNAME29}

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
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
        Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME9}
        Set Suite Variable  ${con_id}
        ${acc_id}=  get_acc_id  ${PUSERNAME29}
        Set Suite Variable  ${acc_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${CUR_DAY}

        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1

        ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${fname2}  ${lname2}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
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

        ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Bill By UUId  ${don_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${CANT_CREATE_BILL}"

JD-TC-DonationBill-UH8
        [Documentation]  Consumer get bill of donation
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Bill By UUId  ${don_id}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DonationBill-UH9
        [Documentation]   get bill by another provider
        ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
        Should Be Equal As Strings    ${resp.status_code}   200 
        ${resp}=  Get Bill By UUId  ${don_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${CANT_CREATE_BILL}"   

JD-TC-DonationBill-UH10
        [Documentation]   get bill without login      
        ${resp}=  Get Bill By UUId  ${don_id}    
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

JD-TC-DonationBill-UH11
        [Documentation]   get bill by invalid id
        ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
        Should Be Equal As Strings    ${resp.status_code}   200 
        ${resp}=  Get Bill By UUId  000 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${INVALID_UID}"   

