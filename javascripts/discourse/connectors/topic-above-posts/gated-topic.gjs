import TopicInGatedCategory from "../../components/topic-in-gated-category";

export default <template>
  <div class="topic-above-post-stream-outlet topic-in-gated-category">
    <TopicInGatedCategory
      @categoryId={{@model.category_id}}
      @tags={{@model.tags}}
      @pageType="topic"
    />
  </div>
</template>
