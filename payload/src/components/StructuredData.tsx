'use client'
import React from 'react'

type Props = { data: unknown }

export function StructuredData({ data }: Props) {
  if (!data) return null
  return (
    <script
      type="application/ld+json"
      // eslint-disable-next-line react/no-danger
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  )
}
