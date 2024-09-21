import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';
import '../../data/ad_data.dart';

const Color primaryColor = Color(0xffF5988D);
const Color backgroundColor = Color(0xfffffff0);

class GeneralKnowledgeQuizScreen extends StatefulWidget {
  final String difficulty;

  const GeneralKnowledgeQuizScreen({Key? key, required this.difficulty})
      : super(key: key);

  @override
  _GeneralKnowledgeQuizScreenState createState() =>
      _GeneralKnowledgeQuizScreenState();
}

class _GeneralKnowledgeQuizScreenState
    extends State<GeneralKnowledgeQuizScreen> {
  int currentQuestionIndex = 0;
  bool showAnswer = false;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  int _questionCount = 0;

  Map<String, List<Map<String, String>>> quizData = {
    '중학생': [
      {"question": "태극기의 가운데 있는 둥근 모양의 문양을 무엇이라고 하나요?", "answer": "태극"},
      {"question": "대한민국의 수도는?", "answer": "서울"},
      {"question": "한글을 만든 조선 시대의 왕은?", "answer": "세종대왕"},
      {"question": "대한민국의 국화는?", "answer": "무궁화"},
      {"question": "삼국시대의 세 나라는?", "answer": "고구려, 백제, 신라"},
      {"question": "한국의 전통 의상은?", "answer": "한복"},
      {"question": "한국의 전통 악기 중 하나로, 12개의 현이 있는 것은?", "answer": "가야금"},
      {"question": "한국의 전통 민화 중 하나로, 호랑이를 그린 그림은?", "answer": "호랑이 그림"},
      {"question": "한국의 전통 음식 중 하나로, 김치를 주재료로 만든 찌개는?", "answer": "김치찌개"},
      {"question": "한국의 대표적인 명절로, 음력 8월 15일에 있는 명절은?", "answer": "추석"},
      {"question": "한국의 국기 일은?", "answer": "10월 3일"},
      {"question": "한국의 대표적인 전통 무예는?", "answer": "태권도"},
      {"question": "한국의 국가는?", "answer": "애국가"},
      {"question": "한국의 수도는 조선 시대에 무엇이라 불렸나요?", "answer": "한양"},
      {"question": "한국의 전통 악기 중 하나로, 바람을 불어 연주하는 것은?", "answer": "대금"},
      {
        "question": "한국의 전통 문양 중 하나로, 오랜 역사를 상징하는 10개의 무늬가 있는 것은?",
        "answer": "십장생"
      },
      {"question": "한국의 대표적인 전통 놀이 중 하나로, 공을 발로 차서 노는 게임은?", "answer": "제기차기"},
      {"question": "한국의 대표적인 사찰 음식 중 하나로, 콩으로 만든 고기 대용품은?", "answer": "콩고기"},
      {"question": "한국에서 가장 긴 강은?", "answer": "한강"},
      {"question": "한국의 대표적인 전통 주택은?", "answer": "한옥"},
      {
        "question": "한국의 대표적인 민속 축제 중 하나로, 부처님 오신 날에 등을 달고 행렬하는 것은?",
        "answer": "연등회"
      },
      {"question": "한국에서 음력으로 새해 첫날을 뭐라고 하나요?", "answer": "설날"},
      {"question": "한국의 전통 악기 중 하나로, 12개의 갈대 관으로 이루어진 것은?", "answer": "퉁소"},
      {"question": "한국의 전통 악기 중 하나로, 25현의 큰 거문고는?", "answer": "가야금"},
      {"question": "한국의 전통 의상 중, 여자들이 머리에 쓰는 장신구는?", "answer": "비녀"},
      {"question": "한국의 대표적인 전통 주택의 지붕 형태는?", "answer": "기와 지붕"},
      {
        "question": "한국의 대표적인 전통 민화 중 하나로, 까치와 호랑이가 그려진 그림은?",
        "answer": "까치호랑이 그림"
      },
      {"question": "한국의 전통 음식 중 하나로, 생선을 발효시켜 만든 음식은?", "answer": "젓갈"},
      {"question": "한국의 대표적인 전통 민화 중 하나로, 해와 달이 그려진 그림은?", "answer": "해와 달 그림"},
      {"question": "한국의 전통 음식 중 하나로, 밀가루 반죽에 소를 넣어 만든 음식은?", "answer": "만두"},
      {"question": "한국의 대표적인 전통 민화 중 하나로, 모란 꽃이 그려진 그림은?", "answer": "모란도"},
      {"question": "한국의 전통 주류 중 하나로, 쌀을 발효시켜 증류한 술은?", "answer": "소주"},
      {"question": "한글은 총 몇 개의 자음과 모음으로 이루어져 있나요?", "answer": "자음 14개, 모음 10개"},
      {
        "question": "한국의 대표적인 전통 놀이 중 하나로, 집 모양의 말판 위에서 윷가락을 던져 노는 게임은?",
        "answer": "윷놀이"
      },
      {"question": "한국의 전통 악기 중 하나로, 작은 북을 양손으로 잡고 치는 것은?", "answer": "소고"},
      {"question": "한국의 국조 새는?", "answer": "까치"},
      {"question": "한국의 국보 1호는?", "answer": "숭례문"},
      {"question": "한국에서 음력 1월 15일은 무슨 날인가요?", "answer": "대보름"},
      {
        "question": "한국의 대표적인 전통 민요 중 하나로, '아리랑'하면 가장 먼저 떠오르는 지역은?",
        "answer": "경기도"
      },
      {
        "question": "한국의 전통 음식 중 하나로, 얇게 썬 쇠고기에 양념을 해서 구운 음식은?",
        "answer": "불고기"
      },
      {"question": "한국의 전통 음식 중 하나로, 메밀로 만든 국수는?", "answer": "막국수"},
      {
        "question": "한국의 대표적인 전통 악기 중 하나로, 해금과 비슷하게 활을 사용해 연주하는 현악기는?",
        "answer": "아쟁"
      },
      {"question": "한국의 전통 의상 중, 여자들이 치마 위에 입는 짧은 저고리는?", "answer": "삼회장저고리"},
      {"question": "조선 시대에 한양에서 평양까지 이어진 길의 이름은?", "answer": "의주로"},
      {"question": "한국의 전통 음식 중 하나로, 쌀을 찐 후 떡메로 쳐서 만든 음식은?", "answer": "떡"},
      {
        "question": "한국의 대표적인 민속 축제 중 하나로, 남원에서 열리는 춘향과 이도령의 사랑을 기리는 축제는?",
        "answer": "춘향제"
      },
      {
        "question": "한국의 전통 음식 중 하나로, 밀가루 반죽에 채소와 고기 등을 넣어 만든 국수 요리는?",
        "answer": "수제비"
      },
      {
        "question": "한국의 대표적인 고전 소설 중 하나로, 심청이 주인공으로 등장하는 작품은?",
        "answer": "심청전"
      },
      {
        "question": "한국의 대표적인 전통 민화 중 하나로, 소나무, 학, 구름 등이 그려진 그림은?",
        "answer": "송학도"
      },
      {
        "question": "한국의 대표적인 민속 축제 중 하나로, 단오 날 전국 각지에서 열리는 씨름 대회는?",
        "answer": "단오장사씨름대회"
      },
      {
        "question": "한국의 전통 음식 중 하나로, 닭고기와 인삼, 대추 등을 넣어 끓인 보양식은?",
        "answer": "삼계탕"
      },
      {"question": "한국 최초의 한글 소설로 알려진 작품은?", "answer": "홍길동전"},
      {"question": "한국의 전통 의상 중, 남자들이 머리에 쓰는 모자는?", "answer": "갓"},
      {
        "question": "한국의 전통 악기 중 하나로, 북과 장구를 합쳐 놓은 듯한 모양의 타악기는?",
        "answer": "좌고"
      },
      {"question": "한국의 대표적인 전통 무용 중 하나로, 부채를 들고 추는 춤은?", "answer": "부채춤"},
      {
        "question": "한국의 전통 음식 중 하나로, 쇠고기를 얇게 저며 육회처럼 먹는 음식은?",
        "answer": "육사시미"
      },
      {"question": "한국의 대표적인 전통 술 중 하나로, 고구마를 발효시켜 만든 술은?", "answer": "고구마소주"},
      {"question": "한국의 전통 의상 중, 여자들의 저고리 위에 입는 겉옷은?", "answer": "당의"},
      {
        "question": "한국의 대표적인 고전 소설 중 하나로, 춘향이 주인공으로 등장하는 작품은?",
        "answer": "춘향전"
      },
      {
        "question": "한국의 대표적인 민속 축제 중 하나로, 강릉에서 음력 정월 대보름에 열리는 축제는?",
        "answer": "강릉단오제"
      },
      {"question": "한국의 전통 음식 중 하나로, 쌀로 만든 술에 식혜를 섞어 만든 음료는?", "answer": "식혜주"},
      {"question": "한국의 대표적인 전통 민화 중 하나로, 매화가 그려진 그림은?", "answer": "매화도"},
      {"question": "한국의 전통 의상 중, 남자들이 바지 위에 입는 긴 저고리는?", "answer": "도포"},
      {
        "question": "한국의 대표적인 전통 민요 중 하나로, '밀양아리랑'하면 떠오르는 지역은?",
        "answer": "경상도"
      },
      {
        "question": "한국 속담 중 '소 잃고 외양간 고친다'는 무슨 뜻인가요?",
        "answer": "이미 일을 그르친 뒤에 뒤늦게 대책을 세움"
      },
      {"question": "한국의 전통 음식 중 하나로, 소의 곱창에 양념을 넣어 만든 음식은?", "answer": "곱창전골"},
      {"question": "한국의 대표적인 전통 민화 중 하나로, 연꽃이 그려진 그림은?", "answer": "연화도"},
      {"question": "한국의 대표적인 전통 민화 중 하나로, 국화꽃이 그려진 그림은?", "answer": "국화도"},
      {"question": "한국의 전통 의상 중, 여자들이 머리에 쓰는 관 모양의 장신구는?", "answer": "떨잠"},
      {
        "question": "한국의 대표적인 민속 축제 중 하나로, 안동에서 음력 9월 9일에 열리는 축제는?",
        "answer": "안동국제탈춤페스티벌"
      },
      {
        "question": "한국의 대표적인 전통 민요 중 하나로, '진도아리랑'하면 가 먼저 떠오르는 지역은?",
        "answer": "전라도"
      },
      {
        "question": "한국의 전통 음식 중 하나로, 김치와 돼지고기, 두부 등을 넣어 만든 찌개는?",
        "answer": "김치찌개"
      },
      {
        "question": "한국의 대표적인 전통 민요 중 하나로, '정선아리랑'하면 떠오르는 지역은?",
        "answer": "강원도"
      },
      {
        "question": "한국의 대표적인 민속 축제 중 하나로, 전주에서 매년 10월에 열리는 국제 영화제는?",
        "answer": "전주국제영화제"
      },
      {
        "question": "탈춤은 한국의 전통 가면극으로 어떤 지역의 것이 유명한가요?",
        "answer": "하회별신굿탈놀이, 봉산탈춤, 강령탈춤, 은율탈춤 등"
      },
      {"question": "한국의 전통 악기 중 하나로, 두 개의 북을 마주 세워 연주하는 타악기는?", "answer": "장고"},
      {"question": "한국의 전통 악기 중 하나로, 작은 징을 손으로 쳐서 연주하는 타악기는?", "answer": "특경"},
      {
        "question": "한국의 전통 음식 중 하나로, 메밀가루를 반죽하여 국수처럼 뽑아낸 후 김치와 함께 먹는 음식은?",
        "answer": "메밀막국수"
      },
      // 더 많은 중학생 수준의 문제 추가
    ],
    '고등학생': [
      {"question": "대한민국의 법정 수도는?", "answer": "세종특별자치시"},
      {"question": "우리나라 최초의 세계문화유산은?", "answer": "석굴암과 불국사"},
      {"question": "임진왜란이 일어난 연도는?", "answer": "1592년"},
      {"question": "4.19 혁명이 일어난 연도는?", "answer": "1960년"},
      {"question": "한국 전쟁이 발발한 연도는?", "answer": "1950년"},
      {"question": "한국의 첫 우주인은?", "answer": "이소연"},
      {"question": "조선의 첫 왕은?", "answer": "태조 이성계"},
      {"question": "일본에 의해 한국이 강제 병합된 연도는?", "answer": "1910년"},
      {"question": "신라를 통일 왕은?", "answer": "태종 무열왕"},
      {"question": "백제의 수도였던 도시는?", "answer": "공주, 부여"},
      {"question": "고구려의 시조는?", "answer": "주몽"},
      {"question": "한국 최초의 민주적 선거는?", "answer": "5.10 총선거"},
      {"question": "고려 시대의 과거제도는?", "answer": "과거 제도, 고려 광종 때 처음 실시"},
      {"question": "삼국 시대에 고구려의 수도였던 곳은?", "answer": "국내성, 평양성"},
      {"question": "한국에서 유교의 경전으로 불리는 책은?", "answer": "사서오경"},
      {"question": "임진왜란 때 이순신 장군이 이끈 함대는?", "answer": "거북선 함대"},
      {"question": "조선 시대의 신분제도는?", "answer": "양반, 중인, 상민, 천민의 사회계층 구조"},
      {"question": "고려에서 원의 내정 간섭 기구는?", "answer": "정동행성"},
      {"question": "독도의 날은 언제인가요?", "answer": "10월 25일"},
      {"question": "제주도의 옛 이름은?", "answer": "탐라국"},
      {"question": "병자호란을 일으킨 나라는?", "answer": "청나라"},
      {
        "question": "한국의 독립운동가 중 '민족대표 33인'으로 불리는 사람은?",
        "answer": "손병희 등 민족 대표 33인"
      },
      {"question": "삼국유사는 어떤 역사서인가요?", "answer": "고려 시대 일연이 저술한 역사서"},
      {"question": "신라의 화랑도에서 여성 화랑을 뭐라고 불렀나요?", "answer": "원화"},
      {"question": "안중근 의사가 이토 히로부미를 저격한 사건은?", "answer": "하얼빈 의거"},
      {"question": "고구려의 지배층은 어떻게 불렸나요?", "answer": "귀족 - 대가, 평민 - 백성"},
      {"question": "발해의 건국자는 누구인가요?", "answer": "대조영"},
      {"question": "세종대왕이 창제한 것으로 알려진 악기는?", "answer": "편경, 자격루 등"},
      {"question": "훈민정음이 창제된 연도는?", "answer": "1443년"},
      {"question": "조선 후기의 실학자 중 북학의를 주장한 인물은?", "answer": "박지원"},
      {
        "question": "조선 후기의 양반들이 즐겨 했던 풍류는?",
        "answer": "선비들이 자연을 벗 삼아 시와 음악을 즐기며 유유자적한 삶을 추구하는 풍류"
      },
      {"question": "고려 시대 불교 종파 중 교종을 대표하는 종파는?", "answer": "천태종, 화엄종"},
      {"question": "고려 시대 최씨 무신 정권 때 만들어진 병종은?", "answer": "삼별초"},
      {"question": "신라 말기에 왕건이 세운 나라는?", "answer": "후백제, 후고구려(태봉)와 함께 후삼국"},
      {"question": "한국 전쟁 중 낙동강 방어선을 사수한 작전의 이름은?", "answer": "낙동강 방어선 사수 작전"},
      {"question": "고려 말기 신진 사대부 세력이 주장한 정치 개혁 방안은?", "answer": "전민변정도감"},
      {"question": "3.1 운동 때 한국의 독립을 선언한 장소는?", "answer": "파고다 공원(현재의 탑골 공원)"},
      {"question": "조선 후기에 서민 문화가 발달하면서 유행한 그림 장르는?", "answer": "풍속화, 민화"},
      {"question": "신라의 민장이 이끈 농민 봉기는?", "answer": "망이, 망소이의 난"},
      {"question": "발해에서 5경 15부 62주라는 지방 행정 구역을 설치한 왕은?", "answer": "선왕 무왕"},
      {
        "question": "삼국 시대의 화랑도는 어떤 조직이었나요?",
        "answer": "신라의 청소년 조직으로, 귀족 자제들의 교육 기관이자 군사 조직"
      },
      {
        "question": "광개토대왕비문에서 왜에 대한 고구려의 우위를 보여주는 사건은?",
        "answer": "고구려의 남하와 백제, 신라, 가야연맹의 고구려에 대한 조공"
      },
      {"question": "조선 전기 문물 제도를 정비한 법전은?", "answer": "경국대전"},
      {"question": "발해가 멸망한 후 고려로 이어진 지역은?", "answer": "고구려의 옛 땅, 요동 지방"},
      {
        "question": "고려 공민왕이 반원 자주 정책을 펼치며 시행한 정책은?",
        "answer": "기철 제거, 쌍성총관부 공격 등"
      },
      {
        "question": "신라의 골품제는 어떤 제도였나요?",
        "answer": "귀족의 혈통과 관등에 따라 서열을 매기는 신분 제도"
      },
      {
        "question": "고려 광종이 호족 세력을 억누르기 위해 실시한 정책은?",
        "answer": "노비안검법, 과거제, 백관의 공복 제정 등"
      },
      {"question": "조선 중기의 사림 세력이 주장한 정치 이념은?", "answer": "성리학적 이념에 따른 도학정치"},
      {"question": "임진왜란 때 의병을 이끌고 승리를 거둔 승려는?", "answer": "서산대사, 사명대사"},
      {"question": "단군신화에 등장하는 환웅의 아버지는?", "answer": "환인"},
      {"question": "고대 한국의 제정일치 사회에서 제사장의 역할을 한 사람은?", "answer": "천군"},
      {
        "question": "고조선의 8조법에 포함되지 않는 법은?",
        "answer": "매매법 (8조법은 인인, 상해, 절도에 관한 법을 다룸)"
      },
      {"question": "장보고가 세운 해상 무역국은?", "answer": "청해진"},
      {"question": "통일 신라시대 최초로 과거제를 시행한 왕은?", "answer": "신문왕"},
      {"question": "조선시대 양반 가문의 족보를 뭐라고 하나요?", "answer": "족보, 세보"},
      {
        "question": "세종대왕이 창제한 것이 아닌 것은?",
        "answer": "측우기 (세종 이전인 고려 시대 충렬왕 때 만들어짐)"
      },
      {"question": "김부식이 저술한 한국 최초의 역사서는?", "answer": "삼국사기"},
      {
        "question": "조선 후기에 서양 문물을 수용하자는 개화사상을 주장한 인물은?",
        "answer": "박지원, 박규수, 홍대용 등"
      },
      {"question": "고려 시대 왕명으로 한문 소설을 모아 엮은 책은?", "answer": "김시습의 금오신화"},
      {"question": "신라의 여성 화랑으로 알려진 인물은?", "answer": "천관녀"},
      {
        "question": "삼국유사에서 신라 건국 신화의 주인공 혁거세의 탄생 설화를 뭐라고 하나요?",
        "answer": "혁거세의 탄생설화, 수로부인설화"
      },
      {"question": "삼국사기에서 가락국의 시조로 등장하는 인물은?", "answer": "수로왕"},
      {"question": "고려 광종이 국자감을 국학으로 고친 이유는?", "answer": "불교 교육을 억제하기 위해"},
      {"question": "고구려 광개토대왕릉비에 기록된 전쟁은?", "answer": "고구려-왜 전쟁에서의 고구려의 승리"},
      {"question": "조선 후기 실학자 중 북학의를 집대성한 책은?", "answer": "박지원의 열하일기"},
      {"question": "조선 후기에 한글 소설이 발달한 이유는?", "answer": "서민 문화의 발달, 한글의 보급"},
      {"question": "신라 지증왕 때 완성된 군사 조직은?", "answer": "9주 5소경 체제"},
      {
        "question": "고구려의 침략으로 백제의 수도가 한성에서 웅진으로 천도한 사건은?",
        "answer": "개로왕 때 고구려의 한성 함락"
      },
      {
        "question": "발해에서 고구려의 전통을 계승한 증거는?",
        "answer": "고구려의 연호와 관등제 사용, 고구려의 옛 영토 확보 등"
      },
      {
        "question": "고려 공민왕이 반원 자주 정책을 펼치며 시행한 정책은?",
        "answer": "기철 제거, 쌍성총관부 공격 등"
      },
      {"question": "고려 시대 대표적인 역사서는?", "answer": "삼국사기, 삼국유사, 고려사, 고려사절요"},
      {
        "question": "고려 태조가 즉위 교서에서 내세운 정책 기조는?",
        "answer": "유교 정치 이념 지향, 불교의 진흥"
      },
      {
        "question": "통일 신라의 발달된 불교 예술품은?",
        "answer": "석굴암, 불국사, 금동 미륵보살 반가 사유상 등"
      },
      {"question": "고려 전기의 대표적인 역사서인 고려도경의 저자는?", "answer": "최승로"},
      {
        "question": "신라 진골 귀족 사이에서 독점적으로 왕위 계승권을 행사한 왕실은?",
        "answer": "성골, 진골 → 김씨, 박씨, 석씨 등"
      },
      {
        "question": "조선 전기 왕권 강화를 위해 친족 관리들로 구성한 기구는?",
        "answer": "의정부 산하 3사(이조, 호조, 예조)"
      },
      {"question": "고려 때 국정 운영의 중추 기구는?", "answer": "중서문하성 -> 삼사 -> 도병마사"},
      {
        "question": "조선 세종 때 편찬된 농사직설은 무엇에 관한 책인가요?",
        "answer": "농업 기술에 대해 정리한 책"
      },
      {
        "question": "이성계가 위화도 회군 때 반대파를 제거하고 왕으로 추대된 곳은?",
        "answer": "정도전 등 개혁파 신진 사대부 세력의 도움으로 왕위에 오른 곳은 개경 -> 한양"
      },
      {
        "question": "신라 진골 귀족 사이에서 독점적으로 왕위 계승권을 행사한 왕실은?",
        "answer": "성골, 진골 → 김씨, 박씨, 석씨 등"
      },
      // 더 많은 고등학생 수준의 문제 추가
    ],
    '성인': [
      {"question": "대한민국의 제1대 대통령은?", "answer": "이승만"},
      {"question": "우리나라 최초의 여성 대법관은?", "answer": "김영란"},
      {"question": "5.18 민주화 운동이 일어난 도시는?", "answer": "광주"},
      {"question": "우리나라 최초의 한글 소설은?", "answer": "홍길동전"},
      {"question": "고려 시대 황제의 칭호는?", "answer": "전하"},
      {"question": "신라의 천년 사직을 지킨 절은?", "answer": "황룡사"},
      {"question": "조선 시대 과거 시험의 최고 급제자를 뭐라고 했을까요?", "answer": "장원"},
      {"question": "백제의 시조는?", "answer": "온조"},
      {"question": "근대 한국 최초의 신문은?", "answer": "한성순보"},
      {"question": "대한민국 임시정부가 수립된 장소는?", "answer": "상하이"},
      {"question": "신라 하대 6두품 세력의 난을 진압한 후 왕위에 오른 태조는?", "answer": "왕건"},
      {"question": "백제의 멸망 이후 백제 부흥 운동을 전개한 사람은?", "answer": "복신, 도침"},
      {"question": "고려 시대 최고의 교육 기관인 국자감의 위치는?", "answer": "개경 인근의 송악산"},
      {"question": "일제 강점기 조선어학회 사건으로 투옥된 인물은?", "answer": "이윤재, 이극로 등"},
      {
        "question": "1980년 5월 18일 광주에서 일어난 민주화 운동은?",
        "answer": "5.18 광주 민주화 운동"
      },
      {"question": "고려 시대에 거란의 침입을 격퇴한 장군은?", "answer": "강감찬, 서희"},
      {"question": "조선 후기 실학자 중 동의보감을 저술한 인물은?", "answer": "허준"},
      {"question": "신라 진흥왕 때 불교를 공인한 사찰은?", "answer": "흥륜사"},
      {"question": "삼국사기에 기록된 고대 한국의 제천 행사는?", "answer": "동맹, 팔관회"},
      {"question": "발해에서 문왕의 공덕을 기리기 위해 세운 사당은?", "answer": "영명사, 자란사"},
      {"question": "조선 전기 문물 제도를 정비한 법전의 명칭은?", "answer": "경국대전"},
      {"question": "서희가 외교 담판을 벌여 강동 6주를 확보한 상대국은?", "answer": "거란(요)"},
      {"question": "신라 선덕여왕 때 설치한 병부는?", "answer": "병부, 상의부"},
      {"question": "망이, 망소이의 난이 일어난 시기는?", "answer": "신라 진흥왕 때"},
      {"question": "단심의 법통설과 토론한 승려는?", "answer": "의상"},
      {"question": "고려 시대 최고 교육 기관으로 성균관의 전신은?", "answer": "국자감, 국학"},
      {"question": "조선 후기 예학과 실학의 대립을 보여주는 사건은?", "answer": "이단상소 사건"},
      {
        "question": "이이와 성혼으로 대표되는 조선 후기 사상은?",
        "answer": "이황의 이(理) 중심 사상, 이이의 기(氣) 중심 사상으로 양분된 성리학"
      },
      {"question": "일연이 저술한 역사서는?", "answer": "삼국유사"},
      {"question": "고구려 광개토대왕비의 건립 시기는?", "answer": "장수왕 때인 414년"},
      {"question": "삼국통일 후 문무왕이 정비한 지방 행정 구역은?", "answer": "9주 5소경 체제"},
      {"question": "고려 전기 대표적인 불교 사상으로 교종을 창시한 사람은?", "answer": "의천"},
      {
        "question": "조선 후기 이익, 정약용 등이 주장한 사회 개혁론의 핵심은?",
        "answer": "토지 제도 개혁, 과학 기술 진흥 등"
      },
      {
        "question": "묘청의 서경 천도 운동이 일어난 배경은?",
        "answer": "풍수지리설에 따른 개경 천도 반대, 금국 정벌 주장"
      },
      {"question": "신라 진흥왕이 한강 유역을 확보하기 위해 백제와 싸운 전투는?", "answer": "관산성 전투"},
      {"question": "고려 무신 정권기에 만들어진 군인 집단은?", "answer": "삼별초"},
      {"question": "고려 공민왕이 반원 자주 정책을 추진하며 제거한 세력은?", "answer": "기철"},
      {"question": "신라에서 화백 회의를 주재한 관직은?", "answer": "상대등"},
      {"question": "조선 세종 때 편찬된 의학서는?", "answer": "향약집성방, 의방유취"},
      {"question": "6두품 세력의 난이 발생한 원인은?", "answer": "호족 세력의 중앙 집권화 반발"},
      {"question": "백제 멸망 후 부흥 운동의 거점이 된 지역은?", "answer": "주류성, 임존성"},
      {"question": "무신 집권기에 고려를 침공한 나라는?", "answer": "몽골(원)"},
      {
        "question": "조선 태종이 왕권 강화를 위해 실시한 사병 혁파 조치는?",
        "answer": "위화도 회군, 제 1차 왕자의 난 진압"
      },
      {"question": "통일 신라 말기에 호족 세력으로 대두한 사람은?", "answer": "견훤, 궁예, 왕건, 양길 등"},
      {"question": "고려 시대 대표적인 무신 세력은?", "answer": "이자겸, 김부의, 채숙 등"},
      {
        "question": "조선 중기의 사림 세력이 주장한 정국 운영 방식은?",
        "answer": "현량과 실시, 경연 강화, 향약 실시 등"
      },
      {"question": "고려 말 권문세족을 견제하기 위해 신진 사대부가 설치한 기구는?", "answer": "도평의사사"},
      {
        "question": "발해에서 고구려 계승 의식을 강조한 증거는?",
        "answer": "고구려 연호 사용, 고구려 관등제 사용, 장군총 축조 등"
      },
      {"question": "백제 멸망 이후 왕실의 마지막 항전지는?", "answer": "임존성"},
      {"question": "신라 말기에 호족 세력으로 일어난 사건은?", "answer": "사벌주 독립, 원종, 애노의 난 등"},
      {"question": "조선 초기 왕권 강화를 위해 친족들로 구성된 권력 기구는?", "answer": "의정부"},
      {"question": "고려 후기 권문세족의 경제적 기반은?", "answer": "농장, 노비 등 사유 재산 증가"},
      {"question": "나말여초 호족의 성장 배경은?", "answer": "지방 세력 성장, 귀족 간 왕위 쟁탈전 등"},
      {"question": "조선 중기 당쟁의 원인은?", "answer": "왕위 계승 문제, 의정부 서사제 운영 문제 등"},
      {"question": "정조 때 시행된 탕평 정책의 목적은?", "answer": "왕권 강화, 세도 정치 타파 등"},
      {"question": "고려 후기 신진 사대부들의 개혁 정책의 핵심은?", "answer": "과전법 개혁, 속대전 편찬 등"},
      {"question": "신라 진흥왕의 업적으로 옳지 않은 것은?", "answer": "불교 공인 (법흥왕 때 이루어짐)"},
      {"question": "고려 광종의 왕권 강화 정책이 아닌 것은?", "answer": "노비안검법 (신문왕 때 시행)"},
      {"question": "백제 성왕이 추진한 정책이 아닌 것은?", "answer": "한강 유역 확보 (진흥왕 때 이루어짐)"},
      {
        "question": "고려 말 신진사대부의 개혁 방안으로 옳지 않은 것은?",
        "answer": "집현전 설치 (조선 초기 태종 때 설치)"
      },
      {
        "question": "조선 왕조 500년을 통틀어 한 번도 외적에 의해 함락된 적 없는 성은?",
        "answer": "남한산성"
      },
      {"question": "임진왜란 때 한산도 앞바다에서 왜군을 크게 무찌른 전투는?", "answer": "명량대첩, 한산도대첩"},
      {
        "question": "고려 시대 대몽 항쟁을 주도한 인물로 옳지 않은 것은?",
        "answer": "김윤후 (대몽 항쟁은 삼별초 중심으로 전개)"
      },
      {
        "question": "고려 말 신진 사대부 정권이 추진한 개혁으로 옳지 않은 것은?",
        "answer": "경국대전 편찬 (조선 초기 세종 때)"
      },
      {
        "question": "병자호란 때 남한산성을 지킨 장군은?",
        "answer": "김상헌, 이시백 등 (참고로 인조는 남한산성에 있지 않았음)"
      },
      {"question": "조선 후기 서원 철폐 정책을 추진한 국왕은?", "answer": "영조, 정조"},
      {"question": "순조 때 진주에서 일어난 농민 봉기는?", "answer": "허삼둘의 난"},
      {"question": "고려와 조선의 전환기에 활동한 인물이 아닌 사람은?", "answer": "최영 (고려 말의 인물)"},
      {"question": "임진왜란 중 이순신이 전사한 전투는?", "answer": "노량해전"},
      {"question": "삼국 중 가장 먼저 불교를 수용한 나라는?", "answer": "고구려"},
      {"question": "고려 시대 장보고가 설치한 해상 무역 기지는?", "answer": "청해진"},
      {"question": "고려의 문신으로 초조대장경의 조판을 감독한 사람은?", "answer": "최유청"},
      {"question": "화랑의 우두머리를 일컫는 말은?", "answer": "원화"},
      {"question": "공민왕의 개혁 정치를 도운 신하는?", "answer": "정도전"},
      {"question": "국보 제1호인 숭례문을 처음 만든 왕은?", "answer": "태조 이성계"},
      {"question": "임진왜란 중 왜군을 가장 먼저 물리친 전투는?", "answer": "행주대첩"},
      {
        "question": "전쟁이 끝난 뒤 백성들의 전쟁 피해를 구제하기 위해 경기도에 설치했던 수양청은?",
        "answer": "제민창"
      },
    ],
  };
  List<int> viewedQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadViewedQuestions();
    _loadBannerAd();
  }

  void _loadViewedQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      viewedQuestions =
          (prefs.getStringList('viewed_questions_${widget.difficulty}') ?? [])
              .map((e) => int.parse(e))
              .toList();
      _filterQuestions();
    });
  }

  void _filterQuestions() {
    quizData[widget.difficulty] = quizData[widget.difficulty]!
        .asMap()
        .entries
        .where((entry) => !viewedQuestions.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    if (quizData[widget.difficulty]!.isEmpty) {
      _showResetDialog();
    }
  }

  void _saveViewedQuestion(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    viewedQuestions.add(index);
    await prefs.setStringList('viewed_questions_${widget.difficulty}',
        viewedQuestions.map((e) => e.toString()).toList());
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < quizData[widget.difficulty]!.length - 1) {
        _saveViewedQuestion(currentQuestionIndex);
        currentQuestionIndex++;
        showAnswer = false;
        _questionCount++;

        if (_questionCount % 5 == 0) {
          _loadBannerAd();
        }
      } else {
        _showResetDialog();
      }
    });
  }

  void showAnswerFunc() {
    setState(() {
      showAnswer = true;
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('퀴즈 완료'),
          content: const Text('모든 퀴즈를 다 풀었습니다. 다시 시작하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('예'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetQuiz();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetQuiz() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('viewed_questions_${widget.difficulty}');
    setState(() {
      viewedQuestions.clear();
      quizData[widget.difficulty]!.shuffle();
      currentQuestionIndex = 0;
      showAnswer = false;
    });
  }

  void _loadBannerAd() {
    _bannerAd?.dispose();
    _isBannerAdReady = false; // 광고 로딩 시작 시 상태를 false로 설정
    setState(() {});
    _bannerAd = BannerAd(
      adUnitId: BANNER_ADID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('${widget.difficulty} 상식퀴즈'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          if (_isBannerAdReady)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          Expanded(
            child: quizData[widget.difficulty]!.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            quizData[widget.difficulty]![currentQuestionIndex]
                                ["question"]!,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (showAnswer)
                          Text(
                            quizData[widget.difficulty]![currentQuestionIndex]
                                ["answer"]!,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.green),
                          ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: showAnswer ? nextQuestion : showAnswerFunc,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white),
                          child: Text(showAnswer ? '다음 문제' : '정답 확인'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
