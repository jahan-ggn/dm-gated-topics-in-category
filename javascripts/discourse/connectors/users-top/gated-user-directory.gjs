import TopicInGatedCategory from "../../components/topic-in-gated-category";

const GatedUserDirectory = <template>
  <TopicInGatedCategory @pageGate={{true}} @pageType={{"directory"}} />
</template>;
export default GatedUserDirectory;
