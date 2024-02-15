*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      JDN
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

***Variables***

@{action}       addService  adjustService  removeService  addItem   adjustItem   removeItem   addServiceLevelDiscount   removeServiceLevelDiscount   addItemLevelDiscount   removeItemLevelDiscount   addBillLevelDiscount   removeBillLevelDiscount   addProviderCoupons   removeProviderCoupons  addJaldeeCoupons   removeJaldeeCoupons   addDisplayNotes   addPrivateNotes



***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}

Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}


*** Test Cases ***

JD-TC-Update JDN Settings-1
    [Documentation]  Update discount percentage in JDN Settings of a valid provider with billable domain

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${domresp}

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}
        ${subdomain}  ${check}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF     '${check}' == '${bool[1]}'

    END
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+850999
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    ${licid}  ${licname}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERPH0}   ${licid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERPH0}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+851
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+852
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    ${PUSERMAIL0}=   Set Variable  ${P_Email}850.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   01s
    
    ${disc_max}=   Random Int   min=100.00   max=500.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${disc_max}=   Random Int   min=200.00   max=400.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[1]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}


JD-TC-Update JDN Settings-2
    [Documentation]  Update maximum discount amount in JDN Settings of a valid provider with billable domain
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[1]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${disc_max}=   Random Int   min=200.00   max=400.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}

    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[1]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}


JD-TC-Update JDN Settings-3
    [Documentation]  Update label in JDN Settings of a valid provider with a non billable domain

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${domresp}

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}
        ${subdomain}  ${check}=  Get Non Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF     '${check}' == '${bool[0]}'

    END
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERPH3}=  Evaluate  ${PUSERNAME}+860
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH3}${\n}
    ${licid}  ${licname}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERPH3}   ${licid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH3}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${PUSERPH3}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERPH3}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+861
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+862
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}860.${test_mail}
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
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   01s
    
    ${label}=   FakerLibrary.word
    Set Suite Variable   ${label}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['label']}   ${label}
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   0.0
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${label}=   FakerLibrary.word
    ${resp}=   Update JDN with Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['label']}   ${label}
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   0.0
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}


JD-TC-Update JDN Settings-4
    [Documentation]  check if already created bill is updated when jdn settings is updated 
    clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${disc_max}=   Random Int   min=100.00   max=500.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}
    
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=300
    ${servicecharge}=   Convert To Number   ${servicecharge}
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${servicecharge} * ${jdn_disc_percentage[0]}
    ${net_rate}=   Evaluate    ${total} / 100  
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${servicecharge} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}     2
    
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${net_rate}

    ${disc_max}=   Random Int   min=200.00   max=400.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[1]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge}


JD-TC-Update JDN Settings-5
    [Documentation]  check if bill is updated when jdn settings is updated and bill is recalculated
    [Setup]  Run Keywords  clear_jdn  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}   AND  clear_queue  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${disc_max1}=   Random Int  min=100.00  max=300.00
    ${disc_max1}=  Convert To Number   ${disc_max1}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max1}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${servicecharge1}   ${resp.json()[0]['totalAmount']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${servicecharge1} * ${jdn_disc_percentage[0]}
    ${net_rate}=   Evaluate    ${total} / 100  
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max1}   ${disc_max1}   ${net_rate}
    ${net_rate1}=   Evaluate   ${servicecharge1} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}     2
    
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${net_rate}

    ${disc_max2}=   Random Int   min=200.00   max=400.00
    ${disc_max2}=  Convert To Number   ${disc_max2}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[1]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max2}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${P1SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge2}=   Random Int  min=100  max=300
    ${servicecharge2}=   Convert To Number   ${servicecharge2}
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge2}  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s2}  ${resp.json()}

    ${reason}=  FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${p1_s2}  1 

    ${resp}=  Update Bill   ${wid}  ${action[0]}   ${service}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${servicecharge}=   Evaluate   ${servicecharge1} + ${servicecharge2}
    ${disc}=   Evaluate   ${servicecharge} * ${jdn_disc_percentage[0]}
    ${disc}=   Evaluate    ${disc} / 100
    ${disc_amount}=  Set Variable If  ${disc} > ${disc_max1}   ${disc_max1}   ${disc}
    ${net_rate}=   Evaluate   ${servicecharge} - ${disc_amount}
    ${net_rate}=  Convert To Number   ${net_rate}     2
    ${disc_amount}=   Convert To Number   ${disc_amount}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${P1SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${disc_amount}


JD-TC-Update JDN Settings-6
    [Documentation]  check if GST bill is updated when jdn settings is updated and bill is recalculated

    Run Keywords   clear_queue  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}  AND  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${disc_max1}=   Random Int  min=100.00  max=300.00
    ${disc_max1}=  Convert To Number   ${disc_max1}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max1}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${servicecharge1}   ${resp.json()[0]['totalAmount']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Test Variable   ${servicecharge2}   ${resp.json()[1]['totalAmount']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${disc}=   Evaluate   ${servicecharge1} * ${jdn_disc_percentage[0]}
    ${disc}=   Evaluate    ${disc} / 100  
    ${disc_amount}=  Set Variable If  ${disc} > ${disc_max1}   ${disc_max1}   ${disc}
    ${total}=   Evaluate   ${servicecharge1} - ${disc_amount}
    ${gst_rate}=   Evaluate   ${total} * ${gstpercentage[2]}
    ${gst_rate}=   Evaluate    ${gst_rate} / 100 
    ${net_rate}=   Evaluate   ${total} + ${gst_rate}
    ${net_rate}=   roundoff   ${net_rate}
    ${disc_amount}=   roundoff   ${disc_amount}
    ${total}=  roundoff   ${total}
    ${gst_rate}=   roundoff   ${gst_rate}

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=${total}  totalTaxAmount=${gst_rate}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}           ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}         ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}            1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}       ${gstpercentage[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}               ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}             ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${disc}

    ${disc_max2}=   Random Int   min=200.00   max=400.00
    ${disc_max2}=  Convert To Number   ${disc_max2}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[1]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max2}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${reason}=  FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${p1_s2}  1 
    ${resp}=  Update Bill   ${wid}  ${action[0]}   ${service}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${servicecharge}=   Evaluate   ${servicecharge1} + ${servicecharge2}
    ${disc}=   Evaluate   ${servicecharge} * ${jdn_disc_percentage[0]}
    ${disc}=   Evaluate    ${disc} / 100
    ${disc_amount}=  Set Variable If  ${disc} > ${disc_max1}   ${disc_max1}   ${disc}
    ${total}=   Evaluate   ${servicecharge} - ${disc_amount}
    ${gst_rate}=   Evaluate   ${total} * ${gstpercentage[2]}
    ${gst_rate}=   Evaluate    ${gst_rate} / 100
    ${gst_rate}=  roundoff   ${gst_rate}
    ${net_rate}=   Evaluate   ${total} + ${gst_rate}
    ${net_rate}=  roundoff   ${net_rate}
    ${disc_amount}=   roundoff   ${disc_amount}


    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=${total}  totalTaxAmount=${gst_rate}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${P1SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${disc_amount}


JD-TC-Update JDN Settings-7
    [Documentation]  check if discounted amount is that of updated discount maximum when jdn settings is updated and bill is recalculated.
    [Setup]  Run Keywords  clear_jdn  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}  AND  clear_queue  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${disc_max1}=   Random Int  min=100.00  max=300.00
    ${disc_max1}=  Convert To Number   ${disc_max1}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max1}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${servicecharge1}   ${resp.json()[0]['totalAmount']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}
    Set Test Variable   ${servicecharge2}   ${resp.json()[1]['totalAmount']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${disc}=   Evaluate   ${servicecharge1} * ${jdn_disc_percentage[0]}
    ${disc}=   Evaluate    ${disc} / 100  
    ${disc_amount}=  Set Variable If  ${disc} > ${disc_max1}   ${disc_max1}   ${disc}
    ${total}=   Evaluate   ${servicecharge1} - ${disc_amount}
    ${gst_rate}=   Evaluate   ${total} * ${gstpercentage[2]}
    ${gst_rate}=   Evaluate    ${gst_rate} / 100 
    ${net_rate}=   Evaluate   ${total} + ${gst_rate}
    ${net_rate}=  roundoff   ${net_rate}
    ${disc_amount}=   roundoff   ${disc_amount}
    ${total}=  roundoff   ${total}
    ${gst_rate}=   roundoff   ${gst_rate}
    
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=${total}  totalTaxAmount=${gst_rate}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${disc}

    ${disc_max2}=   Random Int   min=300.00   max=500.00
    ${disc_max2}=  Convert To Number   ${disc_max2}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[2]}   ${disc_max2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[2]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max2}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${reason}=  FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${p1_s2}  1 

    ${resp}=  Update Bill   ${wid}  ${action[0]}   ${service}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${servicecharge}=   Evaluate   ${servicecharge1} + ${servicecharge2}
    ${disc}=   Evaluate   ${servicecharge} * ${jdn_disc_percentage[0]}
    ${disc}=   Evaluate    ${disc} / 100
    ${disc_amount}=  Set Variable If  ${disc} > ${disc_max1}   ${disc_max1}   ${disc}
    ${total}=   Evaluate   ${servicecharge} - ${disc_amount}
    ${gst_rate}=   Evaluate   ${total} * ${gstpercentage[2]}
    ${gst_rate}=   Evaluate    ${gst_rate} / 100
    ${net_rate}=   Evaluate   ${total} + ${gst_rate}
    ${net_rate}=  roundoff   ${net_rate}
    ${disc_amount}=   roundoff   ${disc_amount}
    ${gst_rate}=   roundoff   ${gst_rate}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=${total}  totalTaxAmount=${gst_rate}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${P1SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${disc_amount}

JD-TC-Update JDN Settings-8
    [Documentation]  check if discounted amount in bill is updated when updated discount maximum in jdn settings is greater than discounted amount and bill is recalculated.
    [Setup]  Run Keywords  clear_jdn  ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}  AND  clear_queue  ${PUSERPH0}  AND   clear_service   ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${disc_max1}=   Random Int  min=100.00  max=200.00
    ${disc_max1}=  Convert To Number   ${disc_max1}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max1}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge1}=   Random Int  min=5000  max=8000
    ${servicecharge1}=   Convert To Number   ${servicecharge1}
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge1}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge2}=   Random Int  min=5000  max=8000
    ${servicecharge2}=   Convert To Number   ${servicecharge2}
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge2}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s2}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${servicecharge1} * ${jdn_disc_percentage[0]}
    ${total}=  Convert To Number   ${total}   2
    ${net_disc}=   Evaluate    ${total} / 100  
    ${net_disc}=  Convert To Number   ${net_disc}   2
    ${amount}=  Set Variable If  ${net_disc} > ${disc_max1}   ${disc_max1}   ${net_rate}
    ${net_rate1}=   Evaluate   ${servicecharge1} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}     2
    ${float_disc_max}=   Convert To Number  ${disc_max1}
    
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${float_disc_max}

    ${disc_max2}=   Random Int   min=400.00   max=600.00
    ${disc_max2}=  Convert To Number   ${disc_max2}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[2]}   ${disc_max2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[2]}
    Should Be Equal As Strings   ${resp.json()['discMax']}   ${disc_max2}
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}

    ${reason}=  FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${p1_s2}  1 

    ${resp}=  Update Bill   ${wid}  ${action[0]}   ${service}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${servicecharge}=   Evaluate   ${servicecharge1} + ${servicecharge2}
    ${disc}=   Evaluate   ${servicecharge} * ${jdn_disc_percentage[0]}
    ${disc}=   Evaluate    ${disc} / 100
    ${disc_amount}=  Set Variable If  ${disc} > ${disc_max1}   ${disc_max1}   ${disc}
    ${net_rate}=   Evaluate   ${servicecharge} - ${disc_amount}
    ${net_rate}=  Convert To Number   ${net_rate}     2
    ${disc_amount}=   Convert To Number   ${disc_amount}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${servicecharge1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${P1SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${servicecharge2}
    Should Be Equal As Strings  ${resp.json()['jdn']['JDNPercentage']}         ${jdn_disc_percentage[0]}
    Should Be Equal As Strings  ${resp.json()['jdn']['maxDiscount']}         ${disc_max1}
    Should Be Equal As Strings  ${resp.json()['jdn']['discount']}         ${disc_amount}


JD-TC-Update JDN Settings-UH1
    [Documentation]  Update label as empty in JDN Settings of a valid provider with non billable domain
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Update JDN with Label    ${EMPTY}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_LABEL_NOT_GIVEN}
    

JD-TC-Update JDN Settings-UH2
    [Documentation]  Update discount percentage as empty in JDN Settings of a valid provider with billable domain
    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int   min=400.00   max=600.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${EMPTY}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_PERCENT_INVALID}


JD-TC-Update JDN Settings-UH3
    [Documentation]  Update discount percentage as something other than standart 5,10,20 in JDN Settings of a valid provider with billable domain
    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int   min=400.00   max=600.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${disc_percent}=   Random Int   min=21   max=50
    ${resp}=   Update JDN with Percentage    ${d_note}   ${disc_percent}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_PERCENT_INVALID}


JD-TC-Update JDN Settings-UH4
    [Documentation]  Update maximun discount for 5% discount as less than 100 in JDN Settings of a valid provider with billable domain

    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${JDN_AMT_INVALID}=  Format String    ${JDN_AMT_INVALID}    ${jdn_disc_max[0]}

    ${disc_max}=   Random Int   min=10.00   max=99.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_AMT_INVALID}


JD-TC-Update JDN Settings-UH5
    [Documentation]  Update maximun discount for 10% discount as less than 200 in JDN Settings of a valid provider with billable domain

    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${JDN_AMT_INVALID}=  Format String    ${JDN_AMT_INVALID}    ${jdn_disc_max[1]}

    ${disc_max}=   Random Int   min=100.00   max=199.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_AMT_INVALID}


JD-TC-Update JDN Settings-UH6
    [Documentation]  Update maximun discount for 20% discount as less than 300 in JDN Settings of a valid provider with billable domain

    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${JDN_AMT_INVALID}=  Format String    ${JDN_AMT_INVALID}    ${jdn_disc_max[2]}

    ${disc_max}=   Random Int   min=200.00   max=299.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${jdn_disc_percentage[2]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_AMT_INVALID}


JD-TC-Update JDN Settings-UH7
    [Documentation]  Update label in JDN Settings of a valid provider with billable domain
    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${JDN_TYPE_INVALID}=   Format String    ${JDN_TYPE_INVALID}    ${jdn_type[0]}

    ${label}=   FakerLibrary.word
    ${resp}=   Update JDN with Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_TYPE_INVALID}


JD-TC-Update JDN Settings-UH8
    [Documentation]  Update discount percentage in JDN Settings of a valid provider with non billable domain

    [Setup]  clear_jdn  ${PUSERPH3}
    ${resp}=  Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${JDN_TYPE_INVALID}=   Format String    ${JDN_TYPE_INVALID}    ${jdn_type[1]}

    ${disc_max}=   Random Int   min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_TYPE_INVALID}


JD-TC-Update JDN Settings-UH9
    [Documentation]  Update discount percentage in JDN Settings of a valid provider with billable domain without discount maximum.
    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int   min=200.00  max=300.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${jdn_disc_percentage[1]}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_DISCOUNT_NOT_GIVEN}


JD-TC-Update JDN Settings-UH10
    [Documentation]  Update JDN Settings of a valid provider with billable domain without discount maximum and discount percentage
    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int   min=200.00  max=300.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${EMPTY}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_DISCOUNT_NOT_GIVEN}


JD-TC-Update JDN Settings-UH11
    [Documentation]   try to Update jdn after disabling jdn.

    ${resp}=  Encrypted Provider Login  ${PUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[0]}
    
    
    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['status']}   ${Qstate[1]}

    ${label}=   FakerLibrary.word
    ${resp}=   Update JDN with Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_CAN_NOT_UPDATE}

JD-TC-Update JDN Settings-UH12
    [Documentation]   update jdn max discount to over 100000.
    [Setup]  clear_jdn  ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int  min=100.00  max=200.00
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${disc_max}=   Random Int   min=100001.00  max=100010.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}   ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}     ${JDN_MAX_AMOUNT_LIMIT}