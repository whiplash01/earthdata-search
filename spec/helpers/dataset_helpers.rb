module Helpers
  module DatasetHelpers
    def use_dataset(id, text)
      before :all do
        fill_in "keywords", with: id
        expect(first_dataset_result).to have_content(text)
      end

      after :all do
        reset_search
        wait_for_xhr
      end
    end

    def view_granule_results
      first_dataset_result.click
      sleep(1) # Wait for sliding transitions
      wait_for_xhr
      wait_for_visualization_load
    end

    def leave_granule_results
      find('#granule-list').click_link('Back to Datasets')
      wait_for_visualization_unload
      sleep(1) # Wait for sliding transitions
    end

    def hook_granule_results(scope=:all)
      before(scope) { view_granule_results }
      after(scope) { leave_granule_results }
    end

    def hook_granule_results_back
      before :all do
        view_granule_results
        leave_granule_results
      end
    end

    private

    def wait_for_visualization_unload
      expect(page).to have_no_selector('.leaflet-tile-pane .leaflet-layer:nth-child(2) canvas')
    end

    def wait_for_visualization_load
      synchronize do
        expect(page.evaluate_script('edsc.page.map.map.loadingLayers')).to eql(0)
      end
    end
  end
end