import '../data/video_data.dart';

enum EventName {
  homeExpose("s1"), // 首页曝光
  homeChannelExpose("fNCsdf2"), // 首页群组模块曝光
  homHistoryExpose("Vmpsdfqq3"), // 首页历史模块曝光
  landpageExpose("YksfsdJ4"), // 承接页曝光（外部进入）
  landpageFail("HRiysdfsVM5"), // 承接页加载失败
  landpagUploadedExpose("RsfdasS1K"), // 承接页最近上传曝光
  playStart("wosdfsfacE"), // 播放
  playSource("NYisdfsUElEIB"), // 主动播放
  playSuc("qSMUsdfadR"), // 播放成功
  playFail("mPssdt"), // 播放失败
  playNext("AZCAoddQZ"), // 下一个
  adReqPlacement("sssfsdfa"), // 广告请求场景
  adReqSuc("badfa"), // 广告请求成功
  adReqFail("babasdfa"), // 广告请求失败
  adNeedShow("asgas"), // 广告应展示场景
  adShowPlacement("xzs"), // 广告展示场景
  adShowFail("wrwt"), // 广告展示失败
  adClick("be"), // 广告点击
  historyExpose("24"), // 历史列表曝光
  historyClick("sbs"), // 历史记录点击
  deeplinkOpen("bas"), // 外部支持深链打开（冷热启动都算）
  channelListExpose("14"), // 频道列表曝光
  channelListClick("wtqw"), // 频道列表点击
  channelExpose("sg"), // 频道页曝光
  premiumExpose("yjVSl"), // 订阅页曝光
  premiumClick("bx"), // 订阅点击
  premiumSuc("s1"), // 订阅成功
  premiumVerify("iFduasdfRaSd"), // 订阅验证成功
  premiumFail("s"); // 订阅失败时机：取消时上报

  final String value;

  const EventName(this.value);
}

enum EventValue {
  file("sf"), // file
  document('docusdgament'), // document
  video("TXFMsdgaseYUYr"), // video
  sub("eLNdmgigsdgxep"), // sub
  history("NaJsgsdgCybxHv"), // history
  playPage("KjsgsEi"), // playpage
  landPage("PvasgasdfutzJ"), // landpage
  native("DkasgQ"), // type native
  landpage_recommend("YzKtasgasLBA"), // landpage_recommend
  channel("cDsgsgkJ"), // channel
  channelpage("jNHwsgsgANz"), // channelpage
  channel_recommend("gssg"), // channel_recommend
  second("RPasdJW"), // second
  RV_second("123YRFId"), // RV_second
  playlist_file("sdfFTj"), // playlist_file
  playlist_recommend("bxGXfEV"), // playlist_recommend
  recommend("bPbsdfJ"), // recommend
  channel_hot("FweDbasfddRR"), // channel_hot
  channel_recently("SbasffBU"), // channel_recently
  channel_file("qWarwouT"), // channel_file
  landpage_hot("FSebsfrq"), // landpage_hot
  landpage_recently("SQbsfMz"), // landpage_recently
  landpage_file("aUbsfawrXvoeBL"), // landpage_file
  cold("mEttNjbasdfVI"), // cold
  hot("ypbsf"), // hot
  open("tsjkSubsflQrA"), // open
  play("SrXaszla"), // play
  playlist_next("HsdfsctzRa"), // playlist_next
  playback("MYkzbasfCUsaP"), // playback
  play_ten("ruGUbsfQM"), // play_10
  home("sTNHsafayLm"), // home
  list("LjbsfNG"), // list
  home_channel("LIbbsfK"), // home_channel
  landpage_avtor("GWoexUbsfPE"), // landpage_avtor
  popup("kVvXIbsfEFSl"), // popup
  page("VOsdfr"), // page
  auto("jwGMmsdfsdtnVc"), // auto
  click("sdfa"), // click
  chennelpage("NIieVVOsdfseo"), // chennelpage
  ad("hOwjYsdfvO"), // AD
  accelerate("NUBsdfsRG"), // accelerate
  yearly("Rzxsdfsdk"), // yearly
  weekly("WslsfsfWBOh"), // weekly
  lifetime("dIefUsdfsffw"), // lifetime
  no_padding("ssadfyUt"), // No padding
  exchange("YRsffIHL"), // exchange
  channellist("EMSZGsfELbtO"), // channellist
  folder("pEsfZ"), // folder
  pause("riasfqB"), // pause
  delayLink("vgsksdfsdfThp"), // DelayLink
  link("jPDsdfluP"), // Link
  cash("dsfasdfa"), // cash
  quick("uSsJernyjXdV"), // quick
  AD_native("tshbsdfpKwlv"); // AD_native

  final String value;

  const EventValue(this.value);
}

enum EventKey {
  value("ITlQasdfkMMgk"), // value
  type("sdfeXxPxvZxlP"), // type
  method("bsfpXOHmupQ"), // method
  source("bsfJJHLvRyTN"), // source
  entrance("bsdfiYSACi"), // entrance
  sub("bemab"), // sub
  code("xSimRyoH"), // code
  history("sdfNhoZ"), // history
  iplayer_uid("bsdfBxBqJjdoJk"), // iplayer_uid
  iplayer_email("bsfrueoSyJ"), // iplayer_email
  iplayer_linkid("usdfgaNSrRFR"), // iplayer_linkid
  iplayer_resource("NsxabsfqljA"), // iplayer_resource
  iplayer_recent_email("RrYfsdfVGg"), // iplayer_recent_email
  iplayer_recent_uid("eDdsfVKU"), // iplayer_recent_uid
  channel_platform("OsqQasfEkdf"), // channel_platform
  iplayer_user("RWNasdfQKCq"), // iplayer_user
  stars("GUsfnd"), // stars
  traceless("LOqsdfzg"), // traceless
  redirection("YYzvsfXJa"), // redirection
  link_source("CJqsdfOT"), // link_source
  is_first_link("TsdfrYcFgLd"), // is_first_link
  ad_count("NIlERvsdfpxH"), // ad_count
  is_new_user("KhWesdfQbr"), // is_new_user
  ad_type("vmsdfm"), // ad_type
  linkid_landpage("SksfMP"), // linkid_landpage
  or_popup("ZEsdfPsno"), // or_popup
  or_auto("sfasfasdfasdf"); // or_auto

  final String name;

  const EventKey(this.name);
}

class EventTool {
  static void otherTabEvent({
    required EventName event,
    bool? oneLink,
    String? value,
    String? code,
    String? history,
    String? entrance,
    EventValue? source,
    EventValue? link,
    EventValue? type,
    EventValue? method,
    VideoData? data,
  }) {
    final Map<String, dynamic> tbaData = {"est121slla": event.value};
    Map<String, dynamic> traineeMap = {};
    if (value != null) {
      traineeMap[EventKey.value.name] = value;
    }
    if (code != null) {
      traineeMap[EventKey.code.name] = code;
    }
    if (history != null) {
      traineeMap[EventKey.history.name] = history;
    }
    if (entrance != null) {
      traineeMap[EventKey.entrance.name] = entrance;
    }
    if (type != null) {
      traineeMap[EventKey.type.name] = type.value;
    }
    if (method != null) {
      traineeMap[EventKey.method.name] = method.value;
    }
    if (source != null) {
      traineeMap[EventKey.source.name] = source.value;
    }
    if (link != null) {
      traineeMap[EventKey.link_source.name] = link.value; //link_source
    }
    if (oneLink != null) {
      traineeMap[EventKey.is_first_link.name] = oneLink; //is_first_link
    }
    tbaData['trabbbbbinee'] = traineeMap;
    // HttpsApi.tbaEventApi(data: tbaData, video: data);
  }
}
