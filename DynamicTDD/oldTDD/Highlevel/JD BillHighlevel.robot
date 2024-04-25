*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}     FacialBody4323
${SERVICE2}     MakeupHair5315
${SERVICE3}     CutHairstylingHair35
${SERVICE4}     Colouring46
${coupon}       onnnam
${item}         QWERTY
${item1}        HJKL
${discount}     soap
${SERVICE1}     Taxable Service
${SERVICE2}     Nontaxable Service
${SERVICE3}     Nontaxable Service2
${rec_type}     Weekly
${self}         0

*** Test Cases ***
JD-TC-Bill Highlevel-1
	[Documentation]  create bill when parent cancel the waitlist and the bill is created to a member
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+17871
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    ${max_party}=  get_maxpartysize_subdomain
    Log    ${max_party}
    Set Suite Variable  ${d1}  ${max_party['domain']}
    Set Suite Variable  ${sd1}  ${max_party['subdomain']}

    ${pkg_id}=   get_highest_license_pkg

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}    ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid1}  ${resp.json()['baseLocation']['id']}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${panCardNumber}=  Generate_pan_number
    Set Suite Variable   ${panCardNumber}
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    Set Suite Variable   ${bankAccountNumber}
    ${bankName}=  FakerLibrary.company
    Set Suite Variable   ${bankName}
    ${ifsc}=  Generate_ifsc_code
    Set Suite Variable   ${ifsc}
    ${panname}=  FakerLibrary.name
    Set Suite Variable   ${panname}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 
    ${gstper}=  Random Element  ${gstpercentage}
    Set Suite Variable   ${gstper}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}   ${GST_num} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200  
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
   
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn}=   Random Int   min=5   max=10
    ${total_amount1}=  Random Int   min=100  max=500
    Set Suite Variable   ${total_amount1}
    ${total_amount2}=  Random Int   min=100  max=500
    Set Suite Variable   ${total_amount2}
    ${min_prepayment}=   Random Int   min=10  max=50
    Set Suite Variable   ${min_prepayment}
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount2}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount2}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_4}  ${resp.json()}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${eTime}=  add_timezone_time  ${tz}  4  00  
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${q_name}=   FakerLibrary.word
    ${parallel}=   Random Int   min=1    max=5
    ${capacity}=   Random Int   min=10   max=20
    ${resp}=  Create Queue  ${q_name}  ${rec_type}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}   ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s


    ${notification}    Random Element     ${bool}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${notification}  100
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Verify Response  ${resp}    maxPartySize=100
    # ${id}=  get_id  ${CUSERNAME5}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${id}  ${resp.json()[0]['id']}
    clear_FamilyMember  ${id}
    ${memberfname1}=  FakerLibrary.first_name
    ${memberlname1}=  FakerLibrary.last_name
    ${memberfname2}=  FakerLibrary.first_name
    ${memberlname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${memberfname1}  ${memberfname1}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id}  ${resp.json()}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${memberfname2}  ${memberlname2}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id1}  ${resp.json()}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_1}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}  ${mem_id}  ${mem_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=PROVIDER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${sId_1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}     ${id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${id}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=PROVIDER  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${sId_1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}     ${id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${mem_id}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=PROVIDER  personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${sId_1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}     ${id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${mem_id1}
    ${reason}  Random Element     ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"
    ${net_rate}=  Evaluate   ${total_amount1} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}
    sleep   5s
    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-2
	[Documentation]  create bill when parent cancel the waitlist and the bill is created to a member(Future waitlist)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.add_timezone_date  ${tz}  1  
    # ${id}=  get_id  ${CUSERNAME5}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_1}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}  ${mem_id}  ${mem_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    ${reason}  Random Element     ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.sentence
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  6s 
    ${resp}=  Get Bill By UUId  ${wid1}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"
    ${net_rate}=  Evaluate   ${total_amount1} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}

    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-3
	[Documentation]  prepayment bill for cancelled member's waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${Conid}=  get_id  ${CUSERNAME5}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_2}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}  ${mem_id}  ${mem_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
    Set Test Variable  ${wid5}  ${wid[1]}
    Set Test Variable  ${wid6}  ${wid[2]}

    ${resp}=  Get Bill By UUId  ${wid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${amunt_paid}=   Evaluate  ${min_prepayment} * 3

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amunt_paid}  ${purpose[0]}  ${wid4}  ${sId_2}  ${bool[0]}   ${bool[1]}  ${Conid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.sentence
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s 
    ${resp}=  Get Bill By UUId  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"

    ${net_rate}=  Evaluate   ${total_amount2} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${amunt_due}=  Evaluate   ${total} - ${amunt_paid}
    ${amunt_due}=  twodigitfloat  ${amunt_due}

    sleep  5s
    ${resp}=  Get Bill By UUId  ${wid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid5}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${amunt_paid}.0  taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amunt_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-4
	[Documentation]  prepayment bill for cancelled member's waitlist (Future date)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${Conid}=  get_id  ${CUSERNAME5}
    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_2}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}  ${mem_id}  ${mem_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${amunt_paid}=   Random Int   min=150  max=250

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amunt_paid}  ${purpose[0]}  ${wid1}  ${sId_2}  ${bool[0]}   ${bool[1]}  ${Conid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${reason}  Random Element     ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.sentence
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"

    ${net_rate}=  Evaluate   ${total_amount2} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${amunt_due}=  Evaluate   ${total} - ${amunt_paid}
    ${amunt_due}=  twodigitfloat  ${amunt_due}

    sleep  5s
    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${amunt_paid}.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amunt_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-5
	[Documentation]  cancel after bill creation

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${id}=  get_id  ${CUSERNAME5}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}  ${mem_id}  ${mem_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}

    ${net_rate}=  Evaluate   ${total_amount1} * 3
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]} 
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0    taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${reason}  Random Element   ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.sentence
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s 
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"

    ${resp}=  Waitlist Action Cancel  ${wid2}  ${reason}  ${message}
    Sleep  5s 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action Cancel  ${wid3}  ${reason}  ${message}
    Sleep  5s 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Bill Highlevel-6
	[Documentation]  cancel after bill creation (Future date)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${id}=  get_id  ${CUSERNAME5}
    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}  ${mem_id}  ${mem_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}

    ${net_rate}=  Evaluate   ${total_amount1} * 3
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.sentence
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Sleep  5s 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"

    ${resp}=  Waitlist Action Cancel  ${wid2}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action Cancel  ${wid3}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Bill Highlevel-7
	[Documentation]  checkin partially paid waitlist and pay complete amount

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${id}=  get_id  ${CUSERNAME5}
    ${DAY}=  db.get_date_by_timezone  ${tz} 
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${net_rate}=  Convert To Number    ${net_rate}   2
    ${amount1}=   Evaluate   ${net_rate} / 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}
    ${amunt_due}=  Evaluate   ${total} - ${amount1}
    ${amunt_due}=  Convert To Number    ${amunt_due}   2
    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...     billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  taxableTotal=${net_rate}  totalTaxAmount=${gst_rate}
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}

    ${resp}=  Accept Payment  ${wid1}  cash  ${amount1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s

    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.sentence
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s

    ${resp}=  Waitlist Action  CHECK_IN  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${amount1}   taxableTotal=${net_rate}  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amunt_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}

    sleep  01s
    ${resp}=  Accept Payment  ${wid1}  cash  ${amunt_due}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${total_paid}=  Evaluate   ${amount1} + ${amunt_due}
    Sleep  5s 
    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...    billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${total_paid}  amountDue=0.0  taxableTotal=${net_rate}  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}

JD-TC-Bill Highlevel-8
	[Documentation]  preapyment bill for a waitlist having only family members

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${Conid}=  get_id  ${CUSERNAME5}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_4}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${mem_id}  ${mem_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pre_paid} =  Evaluate   ${min_prepayment} * 2

    ${resp}=  Make payment Consumer Mock  ${pid}  ${pre_paid}  ${purpose[0]}  ${wid1}  ${sId_4}  ${bool[0]}   ${bool[1]}  ${Conid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${net_rate}=  Evaluate   ${total_amount2} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${amunt_due}=  Evaluate   ${total} - ${pre_paid}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_paid}.0    taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amunt_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE4} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-9
	[Documentation]  preapyment bill for a waitlist having only family members (Future date)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${Conid}=  get_id  ${CUSERNAME5}
    
    ${consumernote}=  FakerLibrary.sentence
    ${DAY}=  db.add_timezone_date  ${tz}  2     
    ${resp}=  Add To Waitlist  ${id}  ${sId_4}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${mem_id}  ${mem_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pre_paid} =  Evaluate   ${min_prepayment} * 2

    ${resp}=  Make payment Consumer Mock  ${pid}  ${pre_paid}  ${purpose[0]}  ${wid1}  ${sId_4}  ${bool[0]}   ${bool[1]}  ${Conid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${net_rate}=  Evaluate   ${total_amount2} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${amunt_due}=  Evaluate   ${total} - ${pre_paid}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_paid}.0    taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amunt_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE4} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-10
	[Documentation]  create bill for a waitlist having only family members

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${id}  ${resp.json()[0]['id']}

    # ${id}=  get_id  ${CUSERNAME3}
    Log  ${resp.json()}
    clear_FamilyMember  ${id}
    ${memberfname1}=  FakerLibrary.first_name
    ${memberlname1}=  FakerLibrary.last_name
    ${memberfname2}=  FakerLibrary.first_name
    ${memberlname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${memberfname1}  ${memberlname1}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem2_id}  ${resp.json()}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${memberfname2}  ${memberlname2}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem2_id1}  ${resp.json()}
    ${consumernote}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${id}  ${sId_1}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${mem2_id}  ${mem2_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${net_rate}=  Evaluate   ${total_amount1} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]} 
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-11
	[Documentation]  create bill for a waitlist having only family members(Future date)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${id}=  get_id  ${CUSERNAME3}
    ${DAY}=  db.add_timezone_date  ${tz}  2   
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_1}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${mem2_id}  ${mem2_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${net_rate}=  Evaluate   ${total_amount1} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-12
	[Documentation]  preapyment bill for a waitlist having only family members after cancel
    
    clear_waitlist  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${Conid}=  get_id  ${CUSERNAME12} 

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${id}  ${resp.json()[0]['id']}

    clear_FamilyMember  ${id}
    ${memberfirstname1}=  FakerLibrary.first_name
    ${memberlname1}=  FakerLibrary.last_name
    ${memberfirstname2}=  FakerLibrary.first_name
    ${memberlname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${memberfirstname1}  ${memberfirstname1}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${memb_id}  ${resp.json()}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${memberfirstname2}  ${memberlname2}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${memb_id1}  ${resp.json()}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_2}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${memb_id}  ${memb_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${net_rate}=  Evaluate   ${total_amount2} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0
    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep   5s 
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_prepayment}  ${purpose[0]}  ${wid2}  ${sId_2}  ${bool[0]}   ${bool[1]}  ${Conid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${net_rate}=  Evaluate   ${total_amount2} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${amount_due}=    Evaluate   ${total} - ${min_prepayment}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_prepayment}.0    taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amount_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${resp}=  Accept Payment  ${wid2}  cash  ${amount_due}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${total_paid}=  Evaluate   ${min_prepayment} + ${amount_due}

    ${resp}=  Get Bill By UUId  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...    billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${total_paid}  amountDue=0.0  taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${resp}=  Settl Bill  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[1]}  billViewStatus=${billViewStatus[0]}  
    ...    billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${total_paid}  amountDue=0.0  taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-13
	[Documentation]  preapyment bill for a waitlist having only family members after cancel (Future date)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${Conid}=  get_id  ${CUSERNAME12}

    ${DAY}=  db.add_timezone_date  ${tz}  1   
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_2}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${memb_id}  ${memb_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${net_rate}=  Evaluate   ${total_amount2} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0
    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  6s 
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_prepayment}  ${purpose[0]}  ${wid2}  ${sId_2}  ${bool[0]}   ${bool[1]}  ${Conid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${net_rate}=  Evaluate   ${total_amount2} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${amount_due}=    Evaluate   ${total} - ${min_prepayment}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_prepayment}.0    taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${amount_due}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-14
	[Documentation]  create bill for a waitlist having only family members after a cancel

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${id}=  get_id  ${CUSERNAME3}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()[0]['id']}

    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${mem2_id}  ${mem2_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${net_rate}=  Evaluate   ${total_amount1} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   5s
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

JD-TC-Bill Highlevel-15
	[Documentation]  create bill for a waitlist having only family members after a cancel (Future date)

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${id}=  get_id  ${CUSERNAME3}
    ${DAY}=  db.add_timezone_date  ${tz}  1   
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  ${consumernote}  ${bool[1]}  ${mem2_id}  ${mem2_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    ${net_rate}=  Evaluate   ${total_amount1} * 2
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${reason}  Random Element    ${waitlist_cancl_reasn}
    ${message}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${reason}  ${message}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   5s
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLED_WAITLIST}"
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    ${total}=  twodigitfloat  ${total}

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0


JD-TC-Bill Highlevel-16
    [Documentation]  Create bill for having taxable service and non taxable service and  0% reiumbursement coupon applied:coupon amount is lessthan non taxable service amount     
    
    ${description}=  FakerLibrary.sentence
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${sd5}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=  Get BusinessDomainsConf
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}  ${d2}_${sd5}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cup_code}=   FakerLibrary.word
    Set Suite Variable   ${cup_code}
    ${cup_name}=    FakerLibrary.name
    Set Suite Variable   ${cup_name}
    ${cup_des}=    FakerLibrary.sentence
    Set Suite Variable   ${cup_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}  
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon     ${cup_code}
    ${resp}=  Create Jaldee Coupon  ${cup_code}  ${cup_name}  ${cup_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cup_code}  ${cup_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode   ${cup_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${jaldee_amt}    ${resp.json()['discountValue']}  
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    Set Suite Variable  ${GSTNO}   ${GST_num}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${cid}=  get_id  ${CUSERNAME3}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[2]['id']}


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    clear_service       ${PUSERPH0}
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn}=   Random Int   min=5   max=10
    ${total_amount1}=  Random Int   min=2000  max=5000
    Set Suite Variable   ${total_amount1}
    ${total_amount2}=  Random Int   min=2000  max=5000
    Set Suite Variable   ${total_amount2}
    ${min_prepayment}=   Random Int   min=10  max=50
    Set Suite Variable   ${min_prepayment}
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount2}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${q_name}=   FakerLibrary.word
    ${parallel}=   Random Int   min=1    max=5
    ${capacity}=   Random Int   min=10   max=20
    ${resp}=  Create Queue  ${q_name}  ${rec_type}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}   ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}  ${sid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${consumernote}=  FakerLibrary.sentence   
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  ${consumernote}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    sleep   5s
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0    taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${service}=  Service Bill  nontaxable  ${sid2}  1
    ${resp}=  Update Bill  ${wid}  addService   ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${net_rate1}=  Evaluate   ${total_amount1} + ${total_amount2}
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${net_rate2}=  Evaluate   ${total_amount2} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate1}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${net_rate1}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}             ${net_rate2}.0

    clear_Discount  ${PUSERPH0}
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    Set Suite Variable    ${desc}
    # ${disc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${disc_amount}=  Set Variable    10.0
    Set Suite Variable    ${disc_amount}
    ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_amount}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}
    ${resp}=   Get Discount By Id  ${discountId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   id=${discountId}   name=${discount}   description=${desc}    discValue=${disc_amount}   calculationType=${calctype[1]}  status=${status[0]}
    ${service}=  Service Bill   discount   ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill   discount   ${sid2}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  5s

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  3s

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cup_code}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dis_ser2}=            Evaluate   ${total_amount2} - ${disc_amount}
    ${net_rate1}=           Evaluate   ${total_amount1} + ${dis_ser2}
    ${ser_amt}=             Evaluate   ${net_rate1} - ${disc_amount}
    ${net_rate}=            Evaluate   ${total_amount1} - ${disc_amount}
    ${net_rate2}=           Evaluate   ${total_amount2} * 1
    ${gst_rate}=            Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=            Evaluate  ${gst_rate}/100
    ${total}=               Evaluate   ${gst_rate} + ${ser_amt}
    ${total}=               Evaluate   ${total} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cup_code}']['value']}   ${jaldee_amt}
    Should Contain  ${resp.json()['jCoupon']['${cup_code}']['systemNote']}          COUPON_APPLIED

    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}             ${dis_ser2}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  ${jaldee_amt}
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0


JD-TC-Bill Highlevel-17    
    [Documentation]  Create bill for having taxable service and non taxable service and 0% reiumbursement coupon applied and coupon amount is more than non taxable service amount
    
    ${description}=  FakerLibrary.sentence
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${sd5}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=  Get BusinessDomainsConf
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}  ${d2}_${sd5}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cup_code}=   FakerLibrary.word
    Set Suite Variable   ${cup_code}
    ${cup_name}=    FakerLibrary.name
    Set Suite Variable   ${cup_name}
    ${cup_des}=    FakerLibrary.sentence
    Set Suite Variable   ${cup_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}  
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon     ${cup_code}
    ${resp}=  Create Jaldee Coupon  ${cup_code}  ${cup_name}  ${cup_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cup_code}  ${cup_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode   ${cup_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${jaldee_amt}    ${resp.json()['discountValue']}  
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    Set Suite Variable  ${GSTNO}   ${GST_num}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${consumernote}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY1}  ${consumernote}  ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    sleep   5s
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${net_rate}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0

    ${service}=  Service Bill  nontaxable  ${sid2}  1
    ${resp}=  Update Bill  ${wid}  addService   ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${net_rate1}=  Evaluate   ${total_amount1} + ${total_amount2}
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${net_rate2}=  Evaluate   ${total_amount2} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate1}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${net_rate1}.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}.0  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}             ${net_rate2}.0

    clear_Discount  ${PUSERPH0}
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    Set Suite Variable    ${desc}
    # ${disc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${disc_amount}=  Set Variable    10.0
    Set Suite Variable    ${disc_amount}
    ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_amount}   ${calctype[1]}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}
    ${resp}=   Get Discount By Id  ${discountId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   id=${discountId}   name=${discount}   description=${desc}    discValue=${disc_amount}   calculationType=${calctype[1]}  status=${status[0]}
    ${service}=  Service Bill   discount   ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill   discount   ${sid2}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cup_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cup_code}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dis_ser2}=            Evaluate   ${total_amount2} - ${disc_amount}
    ${net_rate1}=           Evaluate   ${total_amount1} + ${dis_ser2}
    ${ser_amt}=             Evaluate   ${net_rate1} - ${disc_amount}
    ${net_rate}=            Evaluate   ${total_amount1} - ${disc_amount}
    ${net_rate2}=           Evaluate   ${total_amount2} * 1
    ${gst_rate}=            Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=            Evaluate  ${gst_rate}/100
    ${total}=               Evaluate   ${gst_rate} + ${ser_amt}
    ${total}=               Evaluate   ${total} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cup_code}']['value']}   ${jaldee_amt}
    Should Contain  ${resp.json()['jCoupon']['${cup_code}']['systemNote']}          COUPON_APPLIED

    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${net_rate}  totalTaxAmount=${gst_rate}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                           ${total}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                         ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${total_amount1}.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${net_rate}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}           ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}         ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}               ${total_amount2}.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}             ${dis_ser2}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cup_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  ${jaldee_amt}
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0


*** Comments ***
JD-TC-Bill Highlevel-18    
    [Documentation]  Create bill for having taxable service and non taxable service and 50% reiumbursement coupon applied and coupon amount is more than non taxable service amount    
    
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${bool[1]}    Random Element     ['${bool[1]}','${bool[0]}']
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}   ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}   ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  Onam2022  Onam Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  500  500  ${bool[0]}  ${bool[0]}  50  500  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  Onam2022  Onam Coupon Offer
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  Waitlist  ${bool[1]}  ${notifytype}  0  300.0  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}
    ${resp}=  Update Tax Percentage  18  12DEFBV1100I7Z1
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid3}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid2}
    ${resp}=  Add To Waitlist  ${cid3}  ${sid1}  ${qid1}  ${DAY1}  hi  ${bool[1]}  ${cid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${net_rate}=  Evaluate   ${total_amount1} * 1
    ${gst_rate}=  Evaluate  ${net_rate} * ${gstper}
    ${gst_rate}=  Evaluate  ${gst_rate}/100
    ${total}=    Evaluate   ${gst_rate} + ${net_rate}
    sleep   5s
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=590.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=590.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  nontaxable  ${sid3}  1
    ${resp}=  Update Bill  ${wid}  addService   ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=800.0  billStatus=New  billViewStatus=Notshow  netRate=890.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=890.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  300.0
    ${service}=  Service Bill   discount   ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill   discount   ${sid3}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Onam2022
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  NEW
    ${resp}=  Enable Jaldee Coupon By Provider  Onam2022
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Onam2022
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  Onam2022  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['Onam2022']['value']}  500.0
    Should Contain  ${resp.json()['jCoupon']['Onam2022']['systemNote']}  COUPON_APPLIED
    Verify Response  ${resp}  uuid=${wid}  netTotal=600.0  billStatus=New  billViewStatus=Notshow  netRate=163.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=163.0  taxableTotal=350.0  totalTaxAmount=63.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  400.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  200.0

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Onam2022
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  500.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0

JD-TC-Bill Highlevel-19    
    [Documentation]  Create bill for having taxable service and non taxable service and 100% reiumbursement coupon applied and coupon amount is more than non taxable service amount          
    
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${bool[1]}    Random Element     ['${bool[1]}','${bool[0]}']
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  Onam2023  Onam Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  500  500  ${bool[0]}  ${bool[0]}  100  500  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  consumer first use  500 offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  Onam2023  Onam Coupon Offer
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Tax Percentage  18  12DEFBV1100I7Z2
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid4}=  get_id  ${CUSERNAME6}
    Set Suite Variable  ${cid4}
    ${resp}=  Add To Waitlist  ${cid4}  ${sid1}  ${qid1}  ${DAY1}  hi  ${bool[1]}  ${cid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=590.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=590.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  nontaxable  ${sid3}  1
    ${resp}=  Update Bill  ${wid}  addService   ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=800.0  billStatus=New  billViewStatus=Notshow  netRate=890.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=890.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  300.0
    ${service}=  Service Bill   discount   ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill   discount   ${sid3}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  NEW
    ${resp}=  Enable Jaldee Coupon By Provider  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  Onam2023  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['Onam2023']['value']}  500.0
    Should Contain  ${resp.json()['jCoupon']['Onam2023']['systemNote']}  COUPON_APPLIED
    Verify Response  ${resp}  uuid=${wid}  netTotal=600.0  billStatus=New  billViewStatus=Notshow  netRate=172.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=172.0  taxableTotal=400.0  totalTaxAmount=72.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  400.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  200.0

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  500.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0

JD-TC-Bill Highlevel-20    
    [Documentation]  Create bill for having taxable service and non taxable service and 100% reiumbursement coupon applied and coupon amount is more than non taxable service amount then remove non taxable service    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  service forme  ${sid3}  1 
    ${resp}=  Update Bill   ${wid}  removeService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['Onam2023']['value']}  0.0
    Should Contain  ${resp.json()['jCoupon']['Onam2023']['systemNote']}  MINIMUM_BILL_AMT_REQUIRED
    Verify Response  ${resp}  uuid=${wid}  netTotal=400.0  billStatus=New  billViewStatus=Notshow  netRate=472.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=472.0  taxableTotal=400.0  totalTaxAmount=72.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  400.0
