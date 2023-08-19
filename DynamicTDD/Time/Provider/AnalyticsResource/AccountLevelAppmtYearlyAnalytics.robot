*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           DateTime
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${digits}      0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}        0
${count}       15
${def_amt}     0.0
${zero_value}     0
@{empty_list}
&{jaldee_link_headers}   Content-Type=application/json  BOOKING_REQ_FROM=WEB_LINK
&{ioscons_headers}       Content-Type=application/json  User-Agent=iphone  BOOKING_REQ_FROM=CONSUMER_APP 
&{ios_sp_headers}        Content-Type=application/json  User-Agent=iphone  BOOKING_REQ_FROM=SP_APP  
&{anrd_consapp_headers}  Content-Type=application/json  User-Agent=android  BOOKING_REQ_FROM=CONSUMER_APP  
&{anrd_spapp_headers}    Content-Type=application/json  User-Agent=android  BOOKING_REQ_FROM=SP_APP  


*** Test Cases ***


# JD-TC-YEARLY_PHONE_APPMT-1

#     [Documentation]   take phone in appointments for a provider and check account level analytics for yearly PHONE_APPMT.

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -800
    
#     ${StartDate}=  get_date
#     ${D1} =  Convert Date  ${StartDate}  datetime
#     Log  ${D1.year}  
#     # ${SecondDay}=  db.Add Date   80

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${StartDate}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     Set Test Variable  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=15
#     Set Test Variable  ${s_id1}

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id3}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id3}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id3}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Schedule ById  ${sch_id3}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${StartDate}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id3}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s7_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s7_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s7_slots_len}=  Get Length  ${s7_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${cons_phonein_appt_ids}=  Create List
#     Set Suite Variable   ${cons_phonein_appt_ids}
    
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s7_slots_len}  

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   Take Phonein Appointment For Provider   ${pid}  ${s_id1}  ${sch_id3}  ${StartDate}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Suite Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${cons_phonein_appt_ids}  ${apptid${a}}

#         ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END
    
    
#     change_system_date   350

#     ${SecondDate}=  get_date
#     ${D2} =  Convert Date  ${SecondDate}  datetime
#     Log  ${D2.year}  

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id4}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id4}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id4}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Schedule ById  ${sch_id4}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${SecondDate}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id4}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s7_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s7_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s7_slots_len}=  Get Length  ${s7_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${cons_phonein_appt_ids2}=  Create List
#     Set Suite Variable   ${cons_phonein_appt_ids2}
    
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s7_slots_len}  

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   Take Phonein Appointment For Provider   ${pid}  ${s_id1}  ${sch_id4}  ${SecondDate}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Suite Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${cons_phonein_appt_ids2}  ${apptid${a}}

#         ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END


#     Log List   ${cons_phonein_appt_ids}
#     Log List   ${cons_phonein_appt_ids2}

#     Resetsystem Time
    
#     ${End_Date}=    get_date 

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids) 
#     ${phonein_appt_len2}=  Evaluate  len($cons_phonein_appt_ids2) 
  
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${StartDate}  ${End_Date}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${phonein_appt_len}   
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D2.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${SecondDate}  ${End_Date}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-YEARLY_WALK_IN_APPMT and ARRIVED_APPMT-2

#     [Documentation]   take walk-in appointments for a provider and check account level analytics for Yearly WALK_IN_APPMT and Yearly ARRIVED_APPMT

#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
#         Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     change_system_date   -900

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=15
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  Add customers
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}   ${resp.json()}

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

#     END

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${walkin_appt_ids}=  Create List
#     Set Test Variable   ${walkin_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}

#     END

#     change_system_date   400

#     ${DAY2}=  get_date
#     ${D2} =  Convert Date  ${Day2}  datetime
#     Log  ${D2.year} 

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${walkin_appt_ids2}=  Create List
#     Set Test Variable   ${walkin_appt_ids2}
#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id2}  ${DAY2}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids2}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids2}

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) 
#     ${walkin_appt_len2}=  Evaluate  len($walkin_appt_ids2) 
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D2.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D2.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}


# JD-TC-YEARLY_ONLINE_APPMT and CONFIRMED_APPMT-3

#     [Documentation]   take online appointments for a provider and check account level analytics for ONLINE_APPMT and CONFIRMED_APPMT
#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -750

#     ${DAY1}=  get_date
#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     Set Suite Variable  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=15
#     Set Test Variable  ${s_id1}

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s4_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s4_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s4_slots_len}=  Get Length  ${s4_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${android_appt}=  Create List
#     Set Test Variable   ${android_appt}
    
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s4_slots_len}  

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s4_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${android_appt}  ${apptid${a}}

#         ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     change_system_date   250

#     ${DAY2}=  get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id3}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id3}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id3}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Schedule ById  ${sch_id3}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id3}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s4_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s4_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s4_slots_len}=  Get Length  ${s4_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${android_appt2}=  Create List
#     Set Test Variable   ${android_appt2}
    
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s4_slots_len}  

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s4_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id3}  ${DAY2}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${android_appt2}  ${apptid${a}}

#         ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${android_appt}
#     Log List   ${android_appt2}

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${online_appt_len}=  Evaluate  len($android_appt)
#     ${online_appt_len2}=  Evaluate  len($android_appt2)
   
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${online_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${online_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}


# JD-TC-YEARLY_TELEGRAM_APPMT and WEB_APPMTS-4

#     [Documentation]   take TELEGRAM_APPT for a provider and check account level analytics for Yearly TELEGRAM_APPMT and WEB_TOKENS.
    
#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -800

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     Set Test Variable  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
#     Set Test Variable  ${s_id1}

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  1    1  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s4_slots}=  Create List
   
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s4_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s4_slots_len}=  Get Length  ${s4_slots}
  
#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${appt_ids}=  Create List
   
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s4_slots_len}  

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s4_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=    Take Appointment with ApptMode For Provider   ${appointmentMode[3]}  ${pid}  ${s_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${appt_ids}  ${apptid${a}}

#         ${resp}=    Get consumer Appointment By Id   ${pid}  ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=    Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${appt_ids}

#     change_system_date   400

#     ${DAY2}=  get_date
#     ${D2} =  Convert Date  ${Day2}  datetime
#     Log  ${D2.year} 

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id5}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id5}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  1    1  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Schedule ById  ${sch_id5}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id5}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s4_slots}=  Create List
   
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s4_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s4_slots_len}=  Get Length  ${s4_slots}
  
#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${appt_ids2}=  Create List
   
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s4_slots_len}  

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s4_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=    Take Appointment with ApptMode For Provider   ${appointmentMode[3]}  ${pid}  ${s_id1}  ${sch_id5}  ${DAY2}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${appt_ids2}  ${apptid${a}}

#         ${resp}=    Get consumer Appointment By Id   ${pid}  ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=    Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${appt_ids2}

#     Resetsystem Time

#     ${DayToday}    get_date


#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${tele_appt_len}=  Evaluate  len($appt_ids)
#     ${tele_appt_len2}=  Evaluate  len($appt_ids2)
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['TELEGRAM_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['TELEGRAM_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${tele_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}     ${tele_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D2.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WEB_APPMTS']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WEB_APPMTS']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${tele_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}     ${tele_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D2.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}

# JD-TC-YEARLY_STARTED_APPMT-5

#     [Documentation]   change status from arrived to started and check Yearly STARTED_APPMT metrics
    
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
#         Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -780

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=15
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${eTime}=  add_time   1  45

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  Add customers
#     # ${customers}=  Create List
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}   ${resp.json()}

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

#     END

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${walkin_appt_ids}=  Create List
#     Set Test Variable   ${walkin_appt_ids}

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids}

#     FOR   ${a}  IN RANGE   ${count}

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${walkin_appt_ids[${a}]}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[3]}   ${walkin_appt_ids[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

#     END

#     change_system_date   350

#     ${DAY2}=  get_date
#     ${D2} =  Convert Date  ${Day2}  datetime
#     Log  ${D2.year} 

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${eTime}=  add_time   1  45

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots1}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots1}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots1}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots1}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots1}

#     ${walkin_appt_ids1}=  Create List
#     Set Test Variable   ${walkin_appt_ids1}

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots1[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id2}  ${DAY2}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids1}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids1}

#     FOR   ${a}  IN RANGE   ${count}

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids1[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${walkin_appt_ids1[${a}]}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[6]}   ${walkin_appt_ids1[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids1[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

#     END

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END
    
#     ${appt_len}=  Get Length  ${walkin_appt_ids}
#     ${appt_len2}=  Get Length  ${walkin_appt_ids1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D1.year}

# JD-TC-YEARLY_COMPLETED_APPMT-6

#     [Documentation]   change status from arrived to completed and check Yearly COMPLETED_APPMT metrics
    
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
#         Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -840

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=15
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${eTime}=  add_time   1  45

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  Add customers
#     # ${customers}=  Create List
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}   ${resp.json()}

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

#     END

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${walkin_appt_ids}=  Create List
#     Set Test Variable   ${walkin_appt_ids}

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids}

#     FOR   ${a}  IN RANGE   ${count}

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${walkin_appt_ids[${a}]}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[6]}   ${walkin_appt_ids[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

#     END

#     change_system_date   390

#     ${DAY2}=  get_date
#     ${D2} =  Convert Date  ${Day2}  datetime
#     Log  ${D2.year} 
    
#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${eTime}=  add_time   1  45

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots2}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots2}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots2}

#     ${walkin_appt_ids1}=  Create List
#     Set Test Variable   ${walkin_appt_ids1}

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots2[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id2}  ${DAY2}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids1}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids1}

#     FOR   ${a}  IN RANGE   ${count}

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids1[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${walkin_appt_ids1[${a}]}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[3]}   ${walkin_appt_ids1[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${walkin_appt_ids1[${a}]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

#     END

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   5s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END
    
#     ${appt_len}=  Get Length  ${walkin_appt_ids}
#     ${appt_len2}=    Get Length  ${walkin_appt_ids1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D1.year}


# JD-TC-YEARLY_CANCELLED_APPMT-7

#     [Documentation]   change status from arrived to completed and check Yearly CANCELLED_APPMT metrics
    
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
#         Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -1000

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${eTime}=  add_time   1  45

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  Add customers
#     # ${customers}=  Create List
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}   ${resp.json()}

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

#     END

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${walkin_appt_ids}=  Create List
#     Set Test Variable   ${walkin_appt_ids}

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids}

#     FOR   ${a}  IN RANGE   ${count}

#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        
#         ${resp}=  Cancel Appointment By Consumer  ${apptid${a}}   ${pid}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
        
#         ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     change_system_date   350

#     ${DAY2}=  get_date
#     ${D2} =  Convert Date  ${Day2}  datetime
#     Log  ${D2.year}

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${eTime}=  add_time   1  45

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  GetCustomer
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${walkin_appt_ids1}=  Create List
#     Set Test Variable   ${walkin_appt_ids1}

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id2}  ${DAY2}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${walkin_appt_ids1}  ${apptid${a}}

#     END

#     Log List   ${walkin_appt_ids1}

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END
    
#     ${appt_len}=  Get Length  ${walkin_appt_ids}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D1.year}


# JD-TC-YEARLY_IOS_APPMT-8

#     [Documentation]   take appointments for a provider through CONSUMER_APP and SA_APP and check account level analytics for Yearly IOS_APPMT
    
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
#         Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -900

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${ios_appt_ids}=  Create List
#     Set Test Variable   ${ios_appt_ids}


#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${resp}=  App Consumer Login  ${ioscons_headers}  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   App Take Appointment For Provider   ${ioscons_headers}  ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${ios_appt_ids}  ${apptid${a}}

#         ${resp}=   App Get consumer Appointment By Id   ${ioscons_headers}  ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  App Consumer Logout  ${ioscons_headers}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${ios_appt_ids}

#     ${resp}=   App ProviderLogin  ${ios_sp_headers}  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${DAY2}=  add_date  1

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  
      
#         ${resp}=  App GetCustomer  ${ios_sp_headers}  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  App Take Appointment For Consumer  ${ios_sp_headers}  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY2}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${ios_appt_ids}  ${apptid${a}}

#     END

#     ${resp}=  App GetCustomer  ${ios_sp_headers}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     Log List   ${ios_appt_ids}

#     ${appt_len}=  Get Length  ${ios_appt_ids}
   
#     ${resp}=   App ProviderLogout  ${ios_sp_headers}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     change_system_date   450

#     ${DAY3}=  get_date
#     ${D3} =  Convert Date  ${Day3}  datetime
#     Log  ${D3.year} 

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY3}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots1}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots1}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots1}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${ios_appt_ids2}=  Create List
#     Set Test Variable   ${ios_appt_ids2}


#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${resp}=  App Consumer Login  ${ioscons_headers}  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots1[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   App Take Appointment For Provider   ${ioscons_headers}  ${pid}  ${s_id1}  ${sch_id2}  ${DAY3}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${ios_appt_ids2}  ${apptid${a}}

#         ${resp}=   App Get consumer Appointment By Id   ${ioscons_headers}  ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  App Consumer Logout  ${ioscons_headers}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${ios_appt_ids2}

#     ${appt_len2}=  Get Length  ${ios_appt_ids2}

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['IOS_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}     ${appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['IOS_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['metricId']}  ${appointmentAnalyticsMetrics['IOS_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D3.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}



# JD-TC-YEARLY_ANDROID_APPMT-9

#     [Documentation]   take appointments for a provider through CONSUMER_APP and SA_APP and check account level analytics for Yearly ANDROID_APPMT
    
#     FOR   ${a}  IN RANGE   ${count}
            
#         ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
#         Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -1300

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${android_appt}=  Create List
#     Set Test Variable   ${android_appt}


#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${resp}=  App Consumer Login  ${anrd_consapp_headers}  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   App Take Appointment For Provider   ${anrd_consapp_headers}  ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${android_appt}  ${apptid${a}}

#         ${resp}=   App Get consumer Appointment By Id   ${anrd_consapp_headers}  ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  App Consumer Logout  ${anrd_consapp_headers}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${android_appt}

#     ${resp}=   App ProviderLogin  ${anrd_spapp_headers}  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${DAY2}=  add_date  1

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s1_slots_len}  
      
#         ${resp}=  App GetCustomer  ${anrd_spapp_headers}  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  App Take Appointment For Consumer  ${anrd_spapp_headers}  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY2}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
#         Set Test Variable  ${apptid${a}}  ${apptid[0]}

#         Append To List   ${android_appt}  ${apptid${a}}

#     END

#     ${resp}=  App GetCustomer  ${anrd_spapp_headers}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_cust}=  Get Length  ${resp.json()}

#     Log List   ${android_appt}
   
#     ${resp}=   App ProviderLogout  ${anrd_spapp_headers}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     change_system_date   500

#     ${DAY3}=  get_date
#     ${D3} =  Convert Date  ${Day3}  datetime
#     Log  ${D3.year} 

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY3}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots1}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots1}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots1}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${android_appt1}=  Create List
#     Set Test Variable   ${android_appt1}


#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${resp}=  App Consumer Login  ${anrd_consapp_headers}  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots1[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   App Take Appointment For Provider   ${anrd_consapp_headers}  ${pid}  ${s_id1}  ${sch_id2}  ${DAY3}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${android_appt1}  ${apptid${a}}

#         ${resp}=   App Get consumer Appointment By Id   ${anrd_consapp_headers}  ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  App Consumer Logout  ${anrd_consapp_headers}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${android_appt1}

#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${andr_appt}=  Get Length  ${android_appt}
#     ${andr_appt2}=  Get Length  ${android_appt1}

    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ANDROID_APPMTS']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${andr_appt2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}     ${andr_appt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ANDROID_APPMTS']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['metricId']}  ${appointmentAnalyticsMetrics['ANDROID_APPMTS']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D3.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}

# JD-TC-YEARLY_JALDEE_LINK_APPMT-10

#     [Documentation]   take online appointments for a provider and check account level analytics for Yearly JALDEE_LINK_APPMT.
    
#     ${PO_Number}    Generate random string    7    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
#     Set Test Variable   ${PUSERPH0}
#     ${licid}  ${licname}=  get_highest_license_pkg
#     Log  ${licid}
#     Log  ${licname}

#     ${domresp}=  Get BusinessDomainsConf
#     Log   ${domresp.content}
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${dlen}=  Get Length  ${domresp.json()}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
#     ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#     ${sdom}=  Random Int   min=0  max=${sdlen-1}
#     Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ['Male', 'Female']
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Account Activation  ${PUSERPH0}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.content}    "true"
    
#     ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     change_system_date   -769

#     ${DAY1}=  get_date
#     ${D1} =  Convert Date  ${Day1}  datetime
#     Log  ${D1.year} 

#     ${list}=  Create List  1  2  3  4  5  6  7
#     @{Views}=  Create List  self  all  customersOnly
#     ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
#     ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
#     ${views}=  Evaluate  random.choice($Views)  random
#     ${name1}=  FakerLibrary.name
#     ${name2}=  FakerLibrary.name
#     ${name3}=  FakerLibrary.name
#     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
#     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
#     ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
#     ${bs}=  FakerLibrary.bs
#     ${city}=   get_place
#     ${latti}=  get_latitude
#     ${longi}=  get_longitude
#     ${companySuffix}=  FakerLibrary.companySuffix
#     ${postcode}=  FakerLibrary.postcode
#     ${address}=  get_address
#     ${parking}   Random Element   ${parkingType}
#     ${24hours}    Random Element    ['True','False']
#     ${desc}=   FakerLibrary.sentence
#     ${url}=   FakerLibrary.url
#     ${sTime}=  add_time  0  15
#     ${eTime}=  add_time   0  45
#     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

    

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200

#     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

#     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${spec}=  get_Specializations  ${resp.json()}
    
#     ${resp}=  Update Specialization  ${spec}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=   Get Appointment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

#     FOR  ${i}  IN RANGE   5
#         ${ser_names}=  FakerLibrary.Words  	nb=40
#         ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
#         Exit For Loop If  '${kw_status}'=='True'
#     END

#     ${sernames_len}=  Get Length  ${ser_names}

#     Log List  ${ser_names}

#     comment  Services for check-ins

#     ${SERVICE1}=    Set Variable  ${ser_names[0]}
#     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
#     Set Test Variable  ${s_id1}

#     comment  schedule for appointment

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     comment  take appointment

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id1}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${online_appt_ids}=  Create List
#     Set Test Variable   ${online_appt_ids}


#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${resp}=  App Consumer Login  ${jaldee_link_headers}  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   App Take Appointment For Provider   ${jaldee_link_headers}  ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${online_appt_ids}  ${apptid${a}}

#         ${resp}=   App Get consumer Appointment By Id   ${jaldee_link_headers}  ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  App Consumer Logout  ${jaldee_link_headers}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${online_appt_ids}

#     change_system_date   500

#     ${DAY2}=  get_date
#     ${D2} =  Convert Date  ${Day2}  datetime
#     Log  ${D2.year} 
    
#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${sch_id2}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id2}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s1_slots1}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots1}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s1_slots_len}=  Get Length  ${s1_slots1}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${online_appt_ids1}=  Create List
#     Set Test Variable   ${online_appt_ids1}


#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s1_slots_len}  

#         ${resp}=  App Consumer Login  ${jaldee_link_headers}  ${CUSERNAME${a}}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
#         ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots1[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}

#         ${cnote}=   FakerLibrary.name
#         ${resp}=   App Take Appointment For Provider   ${jaldee_link_headers}  ${pid}  ${s_id1}  ${sch_id2}  ${DAY2}  ${cnote}   ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Test Variable  ${apptid${a}}  ${apptid1}

#         Append To List   ${online_appt_ids1}  ${apptid${a}}

#         ${resp}=   App Get consumer Appointment By Id   ${jaldee_link_headers}  ${pid}  ${apptid1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

#         ${resp}=  App Consumer Logout  ${jaldee_link_headers}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     Log List   ${online_appt_ids1}


#     Resetsystem Time

#     ${DayToday}    get_date

#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${online_appt_len}=  Evaluate  len($online_appt_ids) 
#     ${online_appt_len2}=  Evaluate  len($online_appt_ids1)
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['JALDEE_LINK_APPMT']}  ${DAY1}  ${DayToday}  ${analyticsFrequency[3]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[3]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_appt_len2}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}     ${online_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}    ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['JALDEE_LINK_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['metricId']}  ${appointmentAnalyticsMetrics['JALDEE_LINK_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['year']}   ${D2.year}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['year']}   ${D1.year}


JD-TC-TOTAL_ON_APPMT-11

    [Documentation]   check account level analytics for TOTAL_ON_APPMT, TOTAL_FOR_APPMT, APPMT_FOR_LICENSE_BILLING and BRAND_NEW_APPTS.

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Test Variable   ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    change_system_date   -840

    ${DAY}=  get_date
    ${D1} =  Convert Date  ${Day}  datetime
    Log  ${D1.year} 

    ${DAY1}=    add_date  5

    ${list}=  Create List  1  2  3  4  5  6  7
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=40
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
        Exit For Loop If  '${kw_status}'=='True'
    END

    ${sernames_len}=  Get Length  ${ser_names}

    Log List  ${ser_names}

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=15
    Set Test Variable  ${s_id1}

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${eTime}=  add_time   1  45

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment  Add customers

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    # # ${customers}=  Create List

    # ${NewCustomer}    Generate random string    10    123456789
    # ${NewCustomer}    Convert To Integer  ${NewCustomer}

    # ${resp}=  AddCustomer  ${NewCustomer}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cus}   ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cus}


    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    comment  take appointment

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s1_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s1_slots_len}=  Get Length  ${s1_slots}

    ${online_appt_ids}=  Create List
    Set Test Variable   ${online_appt_ids}
    
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s1_slots[${a}]}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Test Variable  ${apptid$}  ${apptid1}

    Append To List   ${online_appt_ids}  ${apptid$}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Log List   ${online_appt_ids}


    Resetsystem Time

    ${DAY2}=  get_date
    ${D2} =  Convert Date  ${Day2}  datetime
    Log  ${D2.year} 
    
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${eTime}=  add_time   1  45

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${eTime}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    comment  take appointment

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id2}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s1_slots2}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots2}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s1_slots_len}=  Get Length  ${s1_slots2}

    ${walkin_appt_ids1}=  Create List
    Set Test Variable   ${walkin_appt_ids1}

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s1_slots_len}  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots2[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id2}  ${DAY2}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${walkin_appt_ids1}  ${apptid${a}}

    END

    Log List   ${walkin_appt_ids1}


    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   5s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END
    
    ${online_appt_len}=  Get Length  ${online_appt_ids}
    ${appt_len2}=    Get Length  ${walkin_appt_ids1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['TOTAL_FOR_APPMT']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['TOTAL_FOR_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${appt_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['metricId']}  ${appointmentAnalyticsMetrics['TOTAL_FOR_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}   ${def_amt}


    comment  Appointment other than feature appointment


    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['TOTAL_ON_APPMT']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['TOTAL_ON_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${appt_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['BRAND_NEW_APPTS']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['BRAND_NEW_APPTS']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}

    # ${lic_bill_appt_len}=   Evaluate  $online_appt_len - $no_of_cust
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['APPMT_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[3]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['APPMT_FOR_LICENSE_BILLING']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${lic_bill_appt_len}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}