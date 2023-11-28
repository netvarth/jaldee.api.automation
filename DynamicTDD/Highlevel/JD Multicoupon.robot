*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Coupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/acc_ver.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



# Suite Setup     Run Keywords  clear_service  ${PUSERNAME134}  AND   clear_location  ${PUSERNAME134}  AND  clear_jaldeecoupon  ${jcoupon1}  AND  clear_jaldeecoupon  ${jcoupon2}  AND  clear_tax_gstNum  12DEFBV1100M2Z5
*** Variables ***
${sTime}        08:21 AM
${eTime}   	    08:51 PM
${loc}          MND
${longi}        29.524721
${latti}        88.259821
${LsTime}       08:00 AM 
${LeTime}       08:05 AM
${SERVICE1}   FacialBody4323
${SERVICE2}   MakeupHair5315
${SERVICE3}   CutHairstylingHair35
${SERVICE4}   CutHairstylingHair351

${coupon}   MulOnam

${discount}  Mulsoap
${jcoupon1}   CouponMul00
${jcoupon2}   CouponMul01
${coupon}   Mulcoupon
${self}        0
${queue1}  Queue123
${discount}  Discount123
${qnty}  10.0

*** Test Cases ***
JD-TC-Multicoupon-1
	[Documentation]  Create two jaldee coupons and provider coupons and apply in a bill and also add discount
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY}

    ${gstper}=  Random Element  ${gstpercentage}
    Set Suite Variable    ${gstper}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Tax Percentage 
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()['taxPercentage']}   ${gstper}
    Should Be Equal As Strings   ${resp.json()['gstNumber']}   ${GST_num}
    
    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=500   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=     Random Int   min=20   max=90
    ${min_pre1}=    Convert To Number  ${min_pre} 
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount2}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount2}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${min_pre1}  ${ser_amount2}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount3}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount3}
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount3}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_3}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=     Random Int   min=20   max=90
    ${min_pre2}=    Convert To Number  ${min_pre} 
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount4}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount4}
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${min_pre1}  ${ser_amount1}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_4}  ${resp.json()}
  
    sleep  2s

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}

    Sleep  4s
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  0  45  

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}   ${resp.json()}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon  ${jcoupon1}

    ${resp}=   Create Jaldee Coupon   ${jcoupon1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Jaldee Coupon   ${jcoupon2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  20  600  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des1}=    FakerLibrary.Word
    ${resp}=  Push Jaldee Coupon  ${jcoupon1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des2}=    FakerLibrary.Word
    ${resp}=  Push Jaldee Coupon  ${jcoupon2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${PUSERNAME134}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${id}  ${resp.json()[0]['id']}


    ${resp}=  Add To Waitlist  ${id}  ${sId_1}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount1}   billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0    taxableTotal=${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}

    Comment  Apply JC 
    ${resp}=  Get Jaldee Coupons By Coupon_code   ${jcoupon1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon1}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount1}   billStatus=New  billViewStatus=Notshow   billPaymentStatus=NotPaid  totalAmountPaid=0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

    # Comment  Apply Provider Coupon
    # ${des1}=   FakerLibrary.sentence
    # ${pc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${resp}=  Create Coupon  ${coupon}  ${des1}  ${pc_amount}   ${calctype[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${couponId}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${cupn_code}=   FakerLibrary.word
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
    ${services}=   Create list   ${sId_1}   ${sId_2}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${bid}  ${resp.json()['id']}
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid1}  addProviderCoupons   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount1}   billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${pc_amount}  
     

    Comment  Apply Discount on service

    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${disc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_amount}   ${calctype[1]}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}
    ${service}=  Service Bill  service forme  ${sId_1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid1}  addServiceLevelDiscount   ${service}  
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${netTotal1}=   Evaluate   ${ser_amount1}-${disc_amount}
    ${netTotal2}=   Evaluate   ${netTotal1}-${pc_amount}
    ${taxamnt}=     Evaluate   ${netTotal2}*${gstper}/100
    ${taxamnt}=  Convert To Number  ${taxamnt}  2
    ${netrate1}=   Evaluate  ${netTotal2}+${taxamnt}
    ${netrate2}=    Evaluate  ${netrate1}-50.0
    ${netrate2}=  Convert To Number  ${netrate2}  2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${netTotal1}   billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0   amountDue=${netrate2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['id']}  ${couponId}  
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['couponValue']}  ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${pc_amount}  
    
    Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['id']}  ${discountId}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['discountValue']}  ${disc_amount}  

JD-TC-Multicoupon-2

    [Documentation]   using jaldee coupon in different payment status with adding service quantity
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount3}  billStatus=New  billViewStatus=Notshow   billPaymentStatus=NotPaid  totalAmountPaid=0.0   
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3}

    ${service}=  Service Bill  service forme  ${sId_3}  ${qnty}
    # ${ammt}=   Evaluate   ${ser_amount3}*${qnty}
    # ${taxamnt}=  Convert To Number  ${ammt}  2
    ${resp}=  Update Bill   ${wid1}  adjustService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ammt}=   Evaluate   ${ser_amount3}*${qnty}
    ${taxamnt}=  Convert To Number  ${ammt}  2
    ${taxamnt1}=   Evaluate   ${taxamnt}*${gstper}/100
    ${taxamnt2}=  Convert To Number  ${taxamnt1}  2
    ${netRate}=   Evaluate  ${ammt}+${taxamnt2}
    ${netRate1}=   Evaluate  ${netRate}-600.0

    

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ammt}  billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0  taxableTotal=${ammt}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}   ${qnty}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ammt}

    Comment  Apply JC 

    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon2}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ammt}  billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0    taxableTotal=${ammt} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  ${qnty}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ammt}
    Should Contain  ${resp.json()['jCoupon']['${jcoupon2}']['systemNote']}  COUPON_APPLIED


    ${amountDue1}=   Evaluate   ${taxamnt}*10/100
    ${amountDue}=  Convert To Number  ${amountDue1}  2

    ${resp}=  Accept Payment  ${wid1}  ${acceptPaymentBy[0]}   ${amountDue}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ammt}  billStatus=New  billViewStatus=Show    billPaymentStatus=PartiallyPaid     taxableTotal=${ammt}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  ${qnty}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ammt}
    Should Contain  ${resp.json()['jCoupon']['${jcoupon2}']['systemNote']}  COUPON_APPLIED

    