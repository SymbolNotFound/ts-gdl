<script setup lang="ts">
import { useData } from 'vitepress'

// https://vitepress.dev/reference/runtime-api#usedata
const { site, frontmatter } = useData()
</script>

<template>
  <div v-if="frontmatter.home">
    <h1>{{ site.title }}</h1>
    <p>{{ site.description }}</p>
    <ol><span>0. <a href="/">Index</a></span>
      <li><a href="/1-relational">Relational Programs</a></li>
      <li><a href="/2-gdl-intro">Introduction to GDL-II</a></li>
      <li><a href="/3-parsing">Parsing with <code>ts-gdl</code></a></li>
      <li><a href="/4-querying">Querying the Relations DB</a></li>
      <li><a href="/5-playing">Simulating Gameplay</a></li>
      <li><a href="/6-debugging">Debugging Rulebooks</a></li>
      <li><a href="/7-authoring">Tips for Authoring Games</a></li>
      <li><a href="/8-interacting">Building a Game Interface</a></li>
      <li><a href="/9-evaluating">Evaluating Game Qualities</a></li>
    </ol>
  </div>
  <div v-else>
    <a href="/">Home</a>
    <Content />
  </div>
</template>
