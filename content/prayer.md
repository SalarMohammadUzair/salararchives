---
title: prayer
draft: false
tags:
  - islam
---
___
---
title: Salah — What You Are Saying
---

I pray, yet I did not know the meaning. Here is every word, explained.

<link href="https://fonts.googleapis.com/css2?family=Amiri:ital@0;1&display=swap" rel="stylesheet">

<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
.sl-container { padding: 1.5rem 0; font-family: sans-serif; }
.sl-nav { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 1.5rem; }
.sl-btn {
  padding: 6px 14px; border-radius: 999px; font-size: 13px; cursor: pointer;
  border: 1px solid #ccc; background: transparent; color: #555; transition: all 0.15s;
}
.sl-btn:hover { background: #f5f5f5; }
.sl-btn.active { background: #fff; border-color: #888; color: #111; font-weight: 500; }
.sl-card {
  background: #fff; border: 1px solid #e5e5e5;
  border-radius: 12px; padding: 1.5rem; margin-bottom: 1rem;
}
.sl-arabic {
  font-family: 'Amiri', serif; font-size: 26px; line-height: 1.9;
  text-align: right; direction: rtl; color: #111;
  margin-bottom: 0.75rem;
}
.sl-translit { font-size: 14px; color: #888; font-style: italic; margin-bottom: 0.5rem; line-height: 1.6; }
.sl-translation {
  font-size: 15px; color: #111; line-height: 1.7;
  margin-bottom: 1rem; padding-bottom: 1rem;
  border-bottom: 1px solid #eee;
}
.sl-meaning { font-size: 14px; color: #555; line-height: 1.7; }
.sl-step-label { font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em; color: #aaa; margin-bottom: 0.4rem; font-weight: 500; }
.sl-step-title { font-size: 18px; font-weight: 500; color: #111; margin-bottom: 1.25rem; }
.sl-note { background: #f9f9f9; border-radius: 8px; padding: 0.75rem 1rem; font-size: 13px; color: #666; line-height: 1.6; margin-top: 1rem; }
.sl-nav-row { display: flex; gap: 10px; margin-top: 1rem; }
.sl-nav-btn {
  flex: 1; padding: 10px; border-radius: 8px;
  border: 1px solid #ddd; background: transparent; color: #111;
  font-size: 14px; cursor: pointer; transition: background 0.15s;
}
.sl-nav-btn:hover { background: #f5f5f5; }
.sl-nav-btn:disabled { opacity: 0.3; cursor: default; }
.sl-prog-bar { height: 2px; background: #eee; border-radius: 2px; margin-bottom: 1.5rem; overflow: hidden; }
.sl-prog-fill { height: 100%; background: #888; border-radius: 2px; transition: width 0.3s; }
.sl-sep { margin-top: 1.25rem; padding-top: 1.25rem; border-top: 1px solid #eee; }
</style>

<div class="sl-container">
  <div class="sl-prog-bar"><div class="sl-prog-fill" id="sl-prog"></div></div>
  <div class="sl-nav" id="sl-nav"></div>
  <div id="sl-content"></div>
  <div class="sl-nav-row">
    <button class="sl-nav-btn" id="sl-prev" onclick="slGo(-1)">← Previous</button>
    <button class="sl-nav-btn" id="sl-next" onclick="slGo(1)">Next →</button>
  </div>
</div>

<script>
const slSteps = [
  {
    label: "Before you begin", title: "Niyyah — the intention",
    parts: [{
      arabic: "", transliteration: "(silent in heart)",
      translation: "I intend to pray [Fajr / 2 rak'ah] for the sake of Allah.",
      meaning: "Niyyah is not spoken aloud — it is a conscious turning of the heart. You are telling yourself: I am leaving the world behind right now. This act is for Allah alone. The scholars say if your heart knows why you stood, the niyyah is complete."
    }]
  },
  {
    label: "Takbir", title: "Allahu Akbar — opening the prayer",
    parts: [{
      arabic: "اللَّهُ أَكْبَرُ", transliteration: "Allāhu akbar",
      translation: "Allah is greater.",
      meaning: "Not 'Allah is great' — the comparative form matters. Greater than what? Greater than anything on your mind right now. Your work, your worries, your phone, your plans. This one phrase closes the door on dunya and opens the door of the prayer. Say it slowly. Mean it."
    }]
  },
  {
    label: "Qiyam", title: "Standing — Thana, Ta'awwudh, Surah Al-Fatihah",
    parts: [
      {
        arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ",
        transliteration: "Subhānakal-lāhumma wa bihamdika wa tabārakasmuka wa ta'ālā jadduka wa lā ilāha ghayruk",
        translation: "Glory be to You, O Allah, and all praise. Blessed is Your name, exalted is Your majesty. There is no god but You.",
        meaning: "The thana orients you. You are acknowledging three things at once: Allah's perfection, His greatness, and His uniqueness. Said quietly, just between you and Him, before the rest of the prayer begins."
      },
      {
        arabic: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
        transliteration: "A'ūdhu billāhi minash-shaytānir-rajīm",
        translation: "I seek refuge in Allah from the accursed Shaytan.",
        meaning: "You are about to speak to Allah — so you first ask for protection from the one who wants to distract you. A recognition that you cannot guard yourself alone."
      },
      {
        arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        transliteration: "Bismillāhir-rahmānir-rahīm",
        translation: "In the name of Allah, the Most Compassionate, the Most Merciful.",
        meaning: "Al-Rahman: the overwhelming compassion that covers all creation. Al-Raheem: the personal mercy reserved for the believers. You begin in the name of the One who is both vast in mercy and intimate in care."
      },
      {
        arabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿١﴾ الرَّحْمَٰنِ الرَّحِيمِ ﴿٢﴾ مَالِكِ يَوْمِ الدِّينِ ﴿٣﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٤﴾ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿٥﴾ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ﴿٦﴾",
        transliteration: "Al-hamdu lillāhi rabbil-'ālamīn. Ar-rahmānir-rahīm. Māliki yawmid-dīn. Iyyāka na'budu wa iyyāka nasta'īn. Ihdinas-sirātal-mustaqīm. Sirātal-ladhīna an'amta 'alayhim ghayril-maghdūbi 'alayhim wa lad-dāllīn.",
        translation: "All praise is for Allah, Lord of all worlds. The Most Compassionate, Most Merciful. Master of the Day of Judgment. You alone we worship. You alone we ask for help. Guide us to the straight path — the path of those You have blessed, not those who earned anger, nor those who are astray.",
        meaning: "The hadith says Allah divided this surah between Himself and His servant. The first three ayat are praise. Then the pivot — iyyāka na'budu — shifts to direct address: 'YOU alone.' Suddenly you are not speaking about Him. You are speaking to Him. Then the greatest du'a in existence: guide me. Every single rak'ah, you ask again."
      }
    ],
    note: "In Fajr, recite an additional surah after Al-Fatihah. Commonly Al-Ikhlas, Al-Falaq, An-Nas, or a longer surah."
  },
  {
    label: "Ruku", title: "Bowing — Ruku'",
    parts: [
      {
        arabic: "سُبْحَانَ رَبِّيَ الْعَظِيمِ", transliteration: "Subhāna rabbiyal-'azīm",
        translation: "Glory be to my Lord, the Most Great.",
        meaning: "You bow to no one but Allah. Al-'Azeem: the Most Great, the enormous. My Lord — personal, possessive. Not just 'the' Lord. Yours."
      },
      {
        arabic: "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ", transliteration: "Sami'Allāhu liman hamidah",
        translation: "Allah hears whoever praises Him.",
        meaning: "Said as you rise from ruku. Allah hears — present tense, continuous. An affirmation that He is attentive as you transition between postures."
      },
      {
        arabic: "رَبَّنَا لَكَ الْحَمْدُ", transliteration: "Rabbanā lakal-hamd",
        translation: "Our Lord, to You belongs all praise.",
        meaning: "Standing again. After acknowledging He hears, you immediately respond with praise. The conversation is immediate, alive."
      }
    ]
  },
  {
    label: "Sujud", title: "Prostration — Sajdah",
    parts: [
      {
        arabic: "سُبْحَانَ رَبِّيَ الْأَعْلَى", transliteration: "Subhāna rabbiyal-a'lā",
        translation: "Glory be to my Lord, the Most High.",
        meaning: "Your forehead touches the earth — the lowest you can physically go. And in that lowest moment, you declare: My Lord is the Most High. The Prophet ﷺ said: 'The closest a servant is to his Lord is when he is in sujud.' Stay here. Don't rush."
      },
      {
        arabic: "رَبِّ اغْفِرْ لِي", transliteration: "Rabbigh-fir lī",
        translation: "My Lord, forgive me.",
        meaning: "Said in the sitting between the two sujud. Short. Direct. Personal. 'Lī' — for me. You, specifically, asking Him, specifically. This is also where you can make personal du'a."
      }
    ]
  },
  {
    label: "Tashahhud", title: "Sitting — Al-Tashahhud",
    parts: [{
      arabic: "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
      transliteration: "At-tahiyyātu lillāhi was-salawātu wat-tayyibāt. As-salāmu 'alayka ayyuhan-nabiyyu wa rahmatullāhi wa barakātuh. As-salāmu 'alaynā wa 'alā 'ibādillāhis-sālihīn. Ashhadu an lā ilāha illallāhu wa ashhadu anna muhammadan 'abduhu wa rasūluh.",
      translation: "All greetings, prayers, and pure words are for Allah. Peace be upon you, O Prophet, and the mercy of Allah and His blessings. Peace be upon us and upon all righteous servants of Allah. I bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and messenger.",
      meaning: "You greet the Prophet ﷺ directly — 'upon you' — as if he is present. The scholars say he receives the salaam of his ummah. Then you include yourself and every righteous person who ever lived in one universal salaam. Then the shahada — the declaration you will return to on your last breath."
    }]
  },
  {
    label: "Salawat", title: "Blessings on the Prophet ﷺ",
    parts: [{
      arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
      transliteration: "Allāhumma salli 'alā Muhammadin wa 'alā āli Muhammad, kamā sallayta 'alā Ibrāhīma wa 'alā āli Ibrāhīm. Innaka Hamīdun Majīd. Allāhumma bārik 'alā Muhammadin wa 'alā āli Muhammad, kamā bārakta 'alā Ibrāhīma wa 'alā āli Ibrāhīm. Innaka Hamīdun Majīd.",
      translation: "O Allah, send blessings upon Muhammad and the family of Muhammad, as You sent blessings upon Ibrahim and the family of Ibrahim. Truly You are Praiseworthy, Glorious. O Allah, send grace upon Muhammad and the family of Muhammad, as You sent grace upon Ibrahim and the family of Ibrahim. Truly You are Praiseworthy, Glorious.",
      meaning: "You are asking Allah to honour the Prophet ﷺ — the man who brought you this prayer. Allah responds: whoever sends one salawat upon the Prophet ﷺ, Allah sends ten upon them."
    }]
  },
  {
    label: "Salam", title: "Closing — As-Salam",
    parts: [{
      arabic: "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
      transliteration: "As-salāmu 'alaykum wa rahmatullāh",
      translation: "Peace be upon you and the mercy of Allah.",
      meaning: "Said turning right, then left. You are greeting the angels who record your deeds. The prayer began with 'Allahu Akbar' — a closing of the world. It ends with peace — a return to the world, carrying something. You went in one person and came out, hopefully, slightly lighter."
    }],
    note: "After Fajr fard, sit briefly in dhikr before standing — 'Astaghfirullah' ×3, then Ayat al-Kursi and the 3 Quls are common."
  }
];

let slCurrent = 0;

function slRender() {
  const s = slSteps[slCurrent];
  const total = slSteps.length;
  document.getElementById('sl-prog').style.width = ((slCurrent+1)/total*100)+'%';

  document.getElementById('sl-nav').innerHTML = slSteps.map((st,i) =>
    `<button class="sl-btn${i===slCurrent?' active':''}" onclick="slJump(${i})">${st.label}</button>`
  ).join('');

  let html = `<div class="sl-card"><div class="sl-step-label">Step ${slCurrent+1} of ${total}</div><div class="sl-step-title">${s.title}</div>`;

  s.parts.forEach((p, idx) => {
    if (idx > 0) html += `<div class="sl-sep"></div>`;
    if (p.arabic) html += `<div class="sl-arabic">${p.arabic}</div>`;
    if (p.transliteration) html += `<div class="sl-translit">${p.transliteration}</div>`;
    html += `<div class="sl-translation">${p.translation}</div>`;
    html += `<div class="sl-meaning">${p.meaning}</div>`;
  });

  if (s.note) html += `<div class="sl-note">${s.note}</div>`;
  html += `</div>`;

  document.getElementById('sl-content').innerHTML = html;
  document.getElementById('sl-prev').disabled = slCurrent === 0;
  document.getElementById('sl-next').disabled = slCurrent === total - 1;
}

function slGo(d) { slCurrent = Math.max(0, Math.min(slSteps.length-1, slCurrent+d)); slRender(); }
function slJump(i) { slCurrent = i; slRender(); }

slRender();
</script>


 
