import { GlobalConfiguration } from "../cfg"
import { ValidLocale } from "../i18n"
import { QuartzPluginData } from "../plugins/vfile"

interface Props {
  date: Date
  locale?: ValidLocale
}

export type ValidDateType = keyof Required<QuartzPluginData>["dates"]

export function getDate(cfg: GlobalConfiguration, data: QuartzPluginData): Date | undefined {
  if (!cfg.defaultDateType) {
    throw new Error(
      `Field 'defaultDateType' was not set in the configuration object of quartz.config.ts. See https://quartz.jzhao.xyz/configuration#general-configuration for more details.`,
    )
  }
  return data.dates?.[cfg.defaultDateType]
}

const urduMonths = [
  "جنوری", "فروری", "مارچ", "اپریل", "مئی", "جون",
  "جولائی", "اگست", "ستمبر", "اکتوبر", "نومبر", "دسمبر",
]

export function formatDate(d: Date, locale: ValidLocale = "en-US"): string {
  const day = d.getDate()
  const month = urduMonths[d.getMonth()]
  const year = d.getFullYear()
  return `${month} ${day} ${year}`
}

export function Date({ date, locale }: Props) {
  const month = urduMonths[date.getMonth()]
  const day = date.getDate()
  const year = date.getFullYear()
  return (
    <time datetime={date.toISOString()}>
      {month} {day} {year}
    </time>
  )
}