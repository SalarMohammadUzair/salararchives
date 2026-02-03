import { Translation } from "./definition"

export default {
  propertyDefaults: {
    title: "بے عنوان",
    description: "کوئی تفصیل فراہم نہیں کی گئی",
  },
  components: {
    callout: {
      note: "نوٹ",
      abstract: "خلاصہ",
      info: "معلومات",
      todo: "کرنے کا کام",
      tip: "مشورہ",
      success: "کامیابی",
      question: "سوال",
      warning: "انتباہ",
      failure: "ناکامی",
      danger: "خطرہ",
      bug: "بگ",
      example: "مثال",
      quote: "اقتباس",
    },
    backlinks: {
      title: "بیک لنکس",
      noBacklinksFound: "کوئی بیک لنکس نہیں ملے",
    },
    themeToggle: {
      lightMode: "روشن موڈ",
      darkMode: "تاریک موڈ",
    },
    explorer: {
      title: "ایکسپلورر",
    },
    footer: {
      createdWith: "بنایا گیا",
    },
    graph: {
      title: "گراف ویو",
    },
    recentNotes: {
      title: "حالیہ نوٹس",
      seeRemainingMore: ({ remaining }) => `مزید ${remaining} دیکھیں →`,
    },
    transcludes: {
      transcludeOf: ({ targetSlug }) => `${targetSlug} کا ٹرانسکلوڈ`,
      linkToOriginal: "اصل کا لنک",
    },
    search: {
      title: "تلاش",
      searchBarPlaceholder: "کچھ تلاش کریں",
    },
    tableOfContents: {
      title: "فہرست",
    },
    contentMeta: {
      readingTime: ({ minutes }) => `${minutes} منٹ کی پڑھائی`,
    },
  },
  pages: {
    rss: {
      recentNotes: "حالیہ نوٹس",
      lastFewNotes: ({ count }) => `آخری ${count} نوٹس`,
    },
    error: {
      title: "نہیں ملا",
      notFound: "یہ صفحہ یا تو نجی ہے یا موجود نہیں ہے۔",
      home: "ہوم پیج پر واپس جائیں",
    },
    folderContent: {
      folder: "فولڈر",
      itemsUnderFolder: ({ count }) => `${count} آئٹمز`,
    },
    tagContent: {
      tag: "ٹیگ",
      tagIndex: "ٹیگ انڈیکس",
      itemsUnderTag: ({ count }) => `${count} آئٹمز`,
      showingFirst: ({ count }) => `پہلے ${count} ٹیگز دکھا رہا ہے`,
      totalTags: ({ count }) => `کل ${count} ٹیگز`,
    },
  },
} as const satisfies Translation