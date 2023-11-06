import '../models/category.dart';

final List<Category> categories = [
  Category(
      categoryCode: "06", name: "연애", hashTags: ["꿀잼", "남/여사친", "연애", "곤란한질문"]),
  Category(
      categoryCode: "00", name: "일상", hashTags: ["일상", "가벼운 질문", "아이스브레이킹"]),
  Category(categoryCode: "01", name: "친구", hashTags: ["친구", "우정", "기억"]),
  Category(categoryCode: "05", name: "밸런스게임", hashTags: ["꿀잼", "게임", "밸런스"]),
  Category(categoryCode: "02", name: "대학생", hashTags: ["대학생", "학교생활", "시험"]),
  Category(categoryCode: "03", name: "진로", hashTags: ["진로", "미래", "목표"]),
  Category(categoryCode: "04", name: "인생", hashTags: ["인생", "철학", "삶의 의미"]),
];

final List<LiarCategory> liargameCategories = [
  LiarCategory(name: '아이스크림\n종류', categoryCode: '001'),
  LiarCategory(name: '과일', categoryCode: '002'),
  LiarCategory(name: '빵', categoryCode: '003'),
  LiarCategory(name: '축구선수', categoryCode: '004'),
  LiarCategory(name: 'LOL', categoryCode: '005'),
  LiarCategory(name: '직업', categoryCode: '006'),
  LiarCategory(name: '음식', categoryCode: '007'),
  LiarCategory(name: '운동', categoryCode: '008'),
  LiarCategory(name: '아이돌', categoryCode: '009'),
  LiarCategory(name: '드라마', categoryCode: '010'),
  LiarCategory(name: '국가', categoryCode: '011'),
  LiarCategory(name: '동물', categoryCode: '012'),
  LiarCategory(name: '배스킨\n라빈스', categoryCode: '013'),
  LiarCategory(name: '물건', categoryCode: '014'),
  LiarCategory(name: '전자제품', categoryCode: '015'),
  LiarCategory(name: '배우', categoryCode: '016'),
  // ... 필요한 만큼 카테고리를 계속 추가할 수 있습니다.
];
